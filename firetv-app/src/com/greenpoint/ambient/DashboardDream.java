package com.greenpoint.ambient;

import android.service.dreams.DreamService;
import android.webkit.WebView;

/** The screensaver. Fire OS starts this when the stick has been idle; any remote button ends it. */
public class DashboardDream extends DreamService {
    private WebView web;

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        setInteractive(false);   // any button press wakes the TV back to where you were
        setFullscreen(true);
        setScreenBright(true);
        web = Dashboard.createWebView(this);
        setContentView(web);
    }

    @Override
    public void onDreamingStarted() {
        super.onDreamingStarted();
        web.loadUrl(Dashboard.freshUrl());
    }

    @Override
    public void onDreamingStopped() {
        super.onDreamingStopped();
        if (web != null) web.loadUrl("about:blank");
    }

    @Override
    public void onDetachedFromWindow() {
        if (web != null) { web.destroy(); web = null; }
        super.onDetachedFromWindow();
    }
}
