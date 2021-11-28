package com.appliedengineering.aeinstrumentcluster.UI;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.content.res.Configuration;
import android.os.Bundle;
import android.os.StrictMode;

import com.appliedengineering.aeinstrumentcluster.Backend.DataManager;
import com.appliedengineering.aeinstrumentcluster.R;

import com.appliedengineering.aeinstrumentcluster.Backend.BackendDelegate;

public class HomeActivity extends AppCompatActivity {

    private BackendDelegate backendDelegateObj;
    private DataManager dataManager;

    private HomeTopBar homeTopBarFragment;
    private HomeContentScroll homeContentScrollFragment;

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
        setTheme(/*isSystemDarkMode() ? R.style.DarkTheme : */R.style.LightTheme);
        setContentView(R.layout.home_layout);
        //System.out.println(" is dark mode - " + isSystemDarkMode());
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        // Create this frag first because other classes need it
        homeTopBarFragment = new HomeTopBar();

        // Create backend objects
        dataManager = new DataManager();
        backendDelegateObj = new BackendDelegate(dataManager, homeTopBarFragment, this);

        // Add the fragments programmatically
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.top_header, homeTopBarFragment)
                .commit();

        homeContentScrollFragment = new HomeContentScroll(dataManager);
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.content_scroll, homeContentScrollFragment)
                .commit();


        // Make sure to only start execute after everything has been setup
        backendDelegateObj.execute();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (backendDelegateObj != null) { // shouldn't be possible that the obj is ever null
            backendDelegateObj.cancel(true);
        }
    }

}