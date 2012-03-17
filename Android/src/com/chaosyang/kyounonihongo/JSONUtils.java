
package com.chaosyang.kyounonihongo;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class JSONUtils {
    public static final JSONObject getJSONFromUrl_(String url, Context context) {
        JSONObject jsonObject = null;

        HttpClient client = new DefaultHttpClient();
        StringBuilder builder = new StringBuilder();
        HttpGet get = new HttpGet(url);
        try {
            HttpResponse response = client.execute(get);
            BufferedReader reader = new BufferedReader(new InputStreamReader(response.getEntity()
                    .getContent()));
            for (String s = reader.readLine(); s != null; s = reader.readLine()) {
                builder.append(s);
            }

            jsonObject = new JSONObject(builder.toString());

        } catch (Exception e) {

        }
        return jsonObject;
    }

    public static final JSONObject getJSONFromUrl(String url, Context context) {
        SharedPreferences appSharedPrefs = PreferenceManager.getDefaultSharedPreferences(context);
        JSONObject jsonObject = null;
        String result = appSharedPrefs.getString(url, null);
        if (result == null) {
            jsonObject = JSONUtils.getJSONFromUrl_(url, context);
            appSharedPrefs.edit().putString(url, jsonObject.toString()).commit();
        } else {
            try {
                jsonObject = new JSONObject(result);
            } catch (JSONException e) {
            }
        }
        return jsonObject;
    }
}
