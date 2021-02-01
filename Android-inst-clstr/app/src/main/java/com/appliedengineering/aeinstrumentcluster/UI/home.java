package com.appliedengineering.aeinstrumentcluster.UI;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import com.appliedengineering.aeinstrumentcluster.R;

import com.appliedengineering.aeinstrumentcluster.Backend.backendDelegate;

public class home extends AppCompatActivity {

    private static backendDelegate backendDelegateObj;
    private WifiManager.MulticastLock wifiLock;
    //private WifiMonitoringReceiver wifiMonitoringReceiver;

    private Boolean isSystemDarkMode(){
        switch (getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK) {
            case Configuration.UI_MODE_NIGHT_YES:
                return true;
            case Configuration.UI_MODE_NIGHT_NO:
                return false;
        }
        return false;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(isSystemDarkMode() ? R.style.DarkTheme : R.style.LightTheme);
        setContentView(R.layout.home_layout);
        //System.out.println(" is dark mode - " + isSystemDarkMode());

        setWifiLockAcquired(true);

        backendDelegateObj = new backendDelegate();
        backendDelegateObj.execute();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (backendDelegateObj != null) { // shouldn't be possible that the obj is ever null
            backendDelegateObj.cancel(true);
        }
    }

    @Override
    protected void onStart() {
        super.onStart();

    }

    @Override
    protected void onStop(){
        super.onStop();

    }

    private void setWifiLockAcquired(boolean acquired) {
        if (acquired) {
            if (wifiLock != null && wifiLock.isHeld())
                wifiLock.release();

            WifiManager wifi = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
            if (wifi != null) {
                this.wifiLock = wifi.createMulticastLock("MulticastTester");
                wifiLock.acquire();
            }
        } else {
            if (wifiLock != null && wifiLock.isHeld())
                wifiLock.release();
        }
    }

}