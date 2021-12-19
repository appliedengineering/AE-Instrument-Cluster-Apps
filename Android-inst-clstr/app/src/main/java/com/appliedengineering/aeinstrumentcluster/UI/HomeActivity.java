package com.appliedengineering.aeinstrumentcluster.UI;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.StrictMode;

import com.appliedengineering.aeinstrumentcluster.Backend.DataManager;
import com.appliedengineering.aeinstrumentcluster.Backend.TimestampNetworking;
import com.appliedengineering.aeinstrumentcluster.R;

import com.appliedengineering.aeinstrumentcluster.Backend.BackendDelegate;

public class HomeActivity extends AppCompatActivity {

    private BackendDelegate backendDelegateObj;
    private TimestampNetworking timestampNetworking;
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
        timestampNetworking = new TimestampNetworking(this);


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
        timestampNetworking.execute();


        // set up the pull to refresh functionality
        SwipeRefreshLayout refreshLayout = findViewById(R.id.pullToRefresh);
        refreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {

//                Intent mStartActivity = new Intent(HomeActivity.this.getApplicationContext(), HomeActivity.class);
//                int mPendingIntentId = 123456;
//                PendingIntent mPendingIntent = PendingIntent.getActivity(
//                        HomeActivity.this.getApplicationContext(),
//                        mPendingIntentId,
//                        mStartActivity,
//                        PendingIntent.FLAG_CANCEL_CURRENT);
//                AlarmManager mgr = (AlarmManager) HomeActivity.this.getApplicationContext().getSystemService(Context.ALARM_SERVICE);
//                mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 1000, mPendingIntent);
//                HomeActivity.this.onDestroy();
//
//                Intent intent = new Intent(Intent.ACTION_MAIN);
//                intent.addCategory(Intent.CATEGORY_HOME);
//                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
//                startActivity(intent);

            }
        });

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (backendDelegateObj != null) { // shouldn't be possible that the obj is ever null
            backendDelegateObj.cancel(true);
        }
    }

    @Override
    public void onResume() {
        super.onResume();

    }

}