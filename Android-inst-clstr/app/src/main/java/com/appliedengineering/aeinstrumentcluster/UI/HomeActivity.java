package com.appliedengineering.aeinstrumentcluster.UI;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.ListAdapter;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.StrictMode;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.Toast;

import com.appliedengineering.aeinstrumentcluster.Backend.DataManager;
import com.appliedengineering.aeinstrumentcluster.Backend.LogUtil;
import com.appliedengineering.aeinstrumentcluster.Backend.TimestampNetworking;
import com.appliedengineering.aeinstrumentcluster.R;

import com.appliedengineering.aeinstrumentcluster.Backend.BackendDelegate;
import com.google.android.material.switchmaterial.SwitchMaterial;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
        DataManager.dataManager = new DataManager();
        backendDelegateObj = new BackendDelegate(homeTopBarFragment, this);
        timestampNetworking = new TimestampNetworking(this);


        // Add the fragments programmatically
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.top_header, homeTopBarFragment)
                .commit();

        homeContentScrollFragment = new HomeContentScroll();
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.content_scroll, homeContentScrollFragment)
                .commit();


        // Make sure to only start execute after everything has been setup
        backendDelegateObj.execute();
        timestampNetworking.execute();


        // Restart network button
        Button restartNetworkButton = findViewById(R.id.restart_network_button);
        restartNetworkButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                backendDelegateObj.reconnect();
                restartNetworkButton.setText("Restarted!");
                restartNetworkButton.animate().alpha(0.5f).setDuration(1000).withEndAction(new Runnable() {
                    @Override
                    public void run() {
                        // restore the text
                        restartNetworkButton.animate().alpha(1f).setDuration(1000);
                        restartNetworkButton.setText("Restart");
                    }
                });
            }
        });

        // Is network enabled switch
        SwitchMaterial isNetworkEnabled = findViewById(R.id.is_network_enabled);
        isNetworkEnabled.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                backendDelegateObj.setNetworkEnabled(b);
            }
        });

        // Debug switch
        SwitchMaterial generateDebugData = findViewById(R.id.generate_debug_data);
        generateDebugData.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                if(isNetworkEnabled.isChecked()) {
                    generateDebugData.setChecked(false);
                    Toast.makeText(HomeActivity.this, "You must first disable the network!", Toast.LENGTH_LONG).show();
                    return;
                }
                backendDelegateObj.setGenerateDebugData(b);
            }
        });

        // Set up recycler view
        RecyclerView snapshotRecyclerView = findViewById(R.id.snapshot_recycler_view);
        SnapshotRecyclerAdapter snapshotRecyclerAdapter = new SnapshotRecyclerAdapter();
        snapshotRecyclerView.setLayoutManager(new LinearLayoutManager(HomeActivity.this, LinearLayoutManager.VERTICAL, false));
        snapshotRecyclerView.setAdapter(snapshotRecyclerAdapter);
        // add data
        SharedPreferences snapshots = HomeActivity.this.getSharedPreferences("Snapshots", 0);
        snapshotRecyclerAdapter.setData(snapshots.getStringSet("snapshots",  null));

        // Take snapshot button
        Button takeSnapshot = findViewById(R.id.take_snapshot_button);
        takeSnapshot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String serializedData = DataManager.serializeData();
                LogUtil.add("Serialized data: " + serializedData);
                // save the data in sharedPreferences
                SharedPreferences snapshots = HomeActivity.this.getSharedPreferences("Snapshots", 0);
                SharedPreferences.Editor editor = snapshots.edit();

                // read existing data (if any)
                Set<String> snapshotsSet = new HashSet<>();
                if(snapshots.getStringSet("snapshots", null) != null) {
                    snapshotsSet.addAll(snapshots.getStringSet("snapshots", null));
                }
                snapshotsSet.add(serializedData);
                editor.putStringSet("snapshots", snapshotsSet);
                LogUtil.add(snapshotsSet.size() + " <- number of snapshots");
                editor.commit();
                snapshotRecyclerAdapter.setData(snapshotsSet);

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