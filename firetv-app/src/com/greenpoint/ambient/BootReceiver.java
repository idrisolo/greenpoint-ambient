package com.greenpoint.ambient;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/** After a reboot or app update, re-apply the screensaver setting in case Amazon reset it. */
public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context ctx, Intent intent) {
        Dashboard.registerAsScreensaver(ctx);
    }
}
