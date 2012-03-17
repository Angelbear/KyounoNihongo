
package com.chaosyang.kyounonihongo;

import org.json.JSONObject;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.webkit.WebView;
import android.widget.ImageView;

import java.net.URLDecoder;

public class AnswerActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // TODO Auto-generated method stub
        super.onCreate(savedInstanceState);
        setContentView(R.layout.answer);
        answerView = (WebView) findViewById(R.id.answer_view);
        imageView = (LoaderImageView) findViewById(R.id.image);
    }

    @Override
    protected void onResume() {
        // TODO Auto-generated method stub
        super.onResume();
        Intent in = getIntent();
        String url = in.getExtras().getString("url");
        new FetchAnswerTask().execute(url);
    }

    private class FetchAnswerTask extends AsyncTask<String, Integer, JSONObject> {

        @Override
        protected void onPostExecute(JSONObject result) {
            super.onPostExecute(result);
            dismissDialog(PROGRESS_DIALOG_ID);
            try {
                String explain = result.getString("explain");
                String linkCss = "<link rel=\"stylesheet\" href=\"file:///android_asset/frame.css\" type=\"text/css\">";
                answerView.loadDataWithBaseURL("x-data://base", "<html><header>" + linkCss
                        + "</header>" + URLDecoder.decode(explain)
                        + "</body></html>", "text/html", "utf-8", "");
                imageView.setImageDrawable(result.getString("image"));
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
            final JSONObject o = JSONUtils
                    .getJSONFromUrl(String.format(
                            "http://kyounonihonngo.sinaapp.com/result.php?url=%s", params[0]),
                            AnswerActivity.this);

            return o;
        }
    }

    private WebView answerView;

    private LoaderImageView imageView;

    static final int PROGRESS_DIALOG_ID = 1;

    @Override
    protected Dialog onCreateDialog(int id) {
        switch (id) {
            case PROGRESS_DIALOG_ID: {
                ProgressDialog p = new ProgressDialog(this);
                p.setProgressStyle(ProgressDialog.STYLE_SPINNER);
                return p;
            }
        }
        return null;
    }

}
