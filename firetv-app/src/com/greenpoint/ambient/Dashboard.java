package com.greenpoint.ambient;

import android.annotation.SuppressLint;
import android.content.ComponentName;
import android.content.ContentResolver;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/** Shared pieces: the dashboard URL, the WebView setup, and the screensaver registration. */
final class Dashboard {
    static final String URL = "https://idrisolo.github.io/greenpoint-ambient/";
    static final String TAG = "GreenpointAmbient";

    private Dashboard() {}

    /** Page URL with a cache-buster so every screensaver start gets the latest version of the page. */
    static String freshUrl() { return URL + "?t=" + (System.currentTimeMillis() / 60000L); }

    @SuppressLint("SetJavaScriptEnabled")
    static WebView createWebView(Context ctx) {
        final WebView web = new WebView(ctx);
        web.setBackgroundColor(Color.BLACK);
        web.setLayerType(View.LAYER_TYPE_HARDWARE, null);
        web.setFocusable(false);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);          // the page caches its last data in localStorage
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(false);
        s.setCacheMode(WebSettings.LOAD_DEFAULT);
        web.setWebChromeClient(new WebChromeClient());
        web.setWebViewClient(new RetryClient());
        return web;
    }

    /** If the page itself fails to load (Wi-Fi still waking up, etc.), retry shortly. */
    static final class RetryClient extends WebViewClient {
        private final Handler h = new Handler(Looper.getMainLooper());
        @Override
        public void onReceivedError(WebView view, WebResourceRequest req, WebResourceError err) {
            if (req.isForMainFrame()) {
                Log.w(TAG, "Main frame failed: " + err.getDescription());
                h.postDelayed(new Reload(view), 20000);
            }
        }
    }

    static final class Reload implements Runnable {
        private final WebView view;
        Reload(WebView v) { view = v; }
        public void run() { view.loadUrl(freshUrl()); }
    }

    /** Point Fire OS's screensaver setting at our DreamService. Needs WRITE_SECURE_SETTINGS (granted via ADB). */
    static boolean registerAsScreensaver(Context ctx) {
        if (ctx.checkCallingOrSelfPermission("android.permission.WRITE_SECURE_SETTINGS") != PackageManager.PERMISSION_GRANTED) {
            Log.i(TAG, "WRITE_SECURE_SETTINGS not granted; skipping screensaver registration");
            return false;
        }
        try {
            ContentResolver cr = ctx.getContentResolver();
            String me = new ComponentName(ctx, DashboardDream.class).flattenToString();
            String current = Settings.Secure.getString(cr, "screensaver_components");
            if (!me.equals(current)) {
                Settings.Secure.putString(cr, "screensaver_components", me);
                Log.i(TAG, "Screensaver set to " + me + " (was " + current + ")");
            }
            Settings.Secure.putInt(cr, "screensaver_enabled", 1);
            Settings.Secure.putInt(cr, "screensaver_activate_on_sleep", 1);
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Could not set screensaver", e);
            return false;
        }
    }
}
