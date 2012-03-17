
package com.chaosyang.kyounonihongo;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.DatePickerDialog.OnDateSetListener;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.webkit.WebView;
import android.widget.ArrayAdapter;
import android.widget.DatePicker;
import android.widget.ListView;
import android.widget.TextView;

import java.net.URLDecoder;
import java.util.Calendar;

public class KyounoNihongoActivity extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_CUSTOM_TITLE);
        setContentView(R.layout.main);
        getWindow().setFeatureInt(Window.FEATURE_CUSTOM_TITLE, R.layout.custom_title);
        questionView = (WebView) findViewById(R.id.mondai);
        choicesView = (ListView) findViewById(R.id.choices);
        dateView = (TextView) findViewById(R.id.date);

        final Calendar currentDate = Calendar.getInstance();
        mYear = currentDate.get(Calendar.YEAR);
        mMonth = currentDate.get(Calendar.MONTH);
        mDay = currentDate.get(Calendar.DAY_OF_MONTH);
        dateView.setText((String.format("%04d-%02d-%02d", mYear, mMonth + 1, mDay)));
        new FetchQuestionTask().execute((String.format("%04d-%02d-%02d", mYear, mMonth + 1, mDay)));
        new CheckUpdateTask().execute();
    }

    private int mYear;

    private int mMonth;

    private int mDay;

    static final int DATE_DIALOG_ID = 0;

    static final int PROGRESS_DIALOG_ID = 1;

    @Override
    protected void onPause() {
        super.onPause();
    }

    public void chooseDate(View view) {
        showDialog(DATE_DIALOG_ID);
    }

    public void seeAnswer(View view) {
        int index = choicesView.getCheckedItemPosition();
        try {
            String url = mondai.getJSONArray("choice").getJSONObject(index).getString("link");
            Intent in = new Intent(this, AnswerActivity.class);
            in.putExtra("url", url);
            startActivity(in);
        } catch (JSONException e) {
        }
    }

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
            case DATE_DIALOG_ID: {
                return new DatePickerDialog(this, mDateSetListener, mYear, mMonth, mDay);
            }
            case PROGRESS_DIALOG_ID: {
                ProgressDialog p = new ProgressDialog(this);
                p.setProgressStyle(ProgressDialog.STYLE_SPINNER);
                return p;
            }
        }
        return null;
    }

    private DatePickerDialog.OnDateSetListener mDateSetListener = new OnDateSetListener() {
        public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
            mYear = year;
            mMonth = monthOfYear;
            mDay = dayOfMonth;
            dateView.setText((String.format("%04d-%02d-%02d", mYear, mMonth + 1, mDay)));
            new FetchQuestionTask().execute((String.format("%04d-%02d-%02d", mYear, mMonth + 1,
                    mDay)));
        }
    };

    private JSONObject mondai = null;

    private class FetchQuestionTask extends AsyncTask<String, Integer, JSONObject> {

        @Override
        protected void onPostExecute(JSONObject result) {
            super.onPostExecute(result);
            if (result != null) {
                mondai = result;
            }
            dismissDialog(PROGRESS_DIALOG_ID);
            try {
                JSONArray items = result.getJSONArray("choice");
                String[] c = new String[3];
                for (int i = 0; i < items.length(); i++) {
                    c[i] = URLDecoder.decode(items.getJSONObject(i).getString("text"));
                }
                final ArrayAdapter<String> adapter = new ArrayAdapter<String>(
                        KyounoNihongoActivity.this, android.R.layout.simple_list_item_checked, c);
                String linkCss = "<link rel=\"stylesheet\" href=\"file:///android_asset/frame.css\" type=\"text/css\">";
                questionView.loadDataWithBaseURL("x-data://base", "<html><header>" + linkCss
                        + "</header>" + URLDecoder.decode(result.getString("question"))
                        + "</body></html>", "text/html", "utf-8", "");
                choicesView.setAdapter(adapter);
            } catch (Exception e) {

            }
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            showDialog(PROGRESS_DIALOG_ID);

        }

        @Override
        protected JSONObject doInBackground(String... params) {
            final JSONObject o = JSONUtils.getJSONFromUrl(
                    "http://kyounonihonngo.sinaapp.com/index.php?date=" + params[0],
                    KyounoNihongoActivity.this);

            return o;
        }
    }

    private WebView questionView;

    private ListView choicesView;

    private TextView dateView;

    private class CheckUpdateTask extends AsyncTask<String, Integer, JSONObject> {

        @Override
        protected void onPostExecute(final JSONObject result) {
            // TODO Auto-generated method stub
            super.onPostExecute(result);
            try {
                int versionUpdate = result.getJSONObject("android").getInt("version");
                PackageManager manager = getPackageManager();
                try {
                    PackageInfo info = manager.getPackageInfo(getPackageName(), 0);
                    int versionCode = info.versionCode; // °æ±¾ºÅ
                    if (versionCode < versionUpdate) {

                        AlertDialog.Builder builder = new AlertDialog.Builder(
                                KyounoNihongoActivity.this).setMessage(
                                getString(R.string.update_message)).setPositiveButton(
                                android.R.string.ok, new OnClickListener() {
                                    public void onClick(DialogInterface paramDialogInterface,
                                            int paramInt) {
                                        try {
                                            Intent it = new Intent(Intent.ACTION_VIEW, Uri
                                                    .parse(result.getJSONObject("android")
                                                            .getString("link")));
                                            startActivity(it);
                                        } catch (JSONException e) {
                                        }
                                    }
                                }).setNegativeButton(android.R.string.cancel, null);
                        builder.create().show();
                    }
                } catch (Exception e) {

                }
            } catch (Exception e) {

            }
        }

        @Override
        protected JSONObject doInBackground(String... paramArrayOfParams) {
            JSONObject o = JSONUtils.getJSONFromUrl_(
                    "http://kyounonihonngo.sinaapp.com/update.php", KyounoNihongoActivity.this);
            return o;
        }

    }

    @Override
    protected void onResume() {
        // TODO Auto-generated method stub
        super.onResume();

        
    }

    @Override
    protected void onStart() {
        // TODO Auto-generated method stub
        super.onStart();
    }

    @Override
    protected void onStop() {
        // TODO Auto-generated method stub
        super.onStop();
    }
}
