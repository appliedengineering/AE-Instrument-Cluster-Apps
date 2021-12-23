package com.appliedengineering.aeinstrumentcluster.UI;

import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.StrictMode;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.appliedengineering.aeinstrumentcluster.Backend.BackendDelegate;
import com.appliedengineering.aeinstrumentcluster.Backend.DataManager;
import com.appliedengineering.aeinstrumentcluster.Backend.TimestampNetworking;
import com.appliedengineering.aeinstrumentcluster.Backend.util.animation.AnimationUtil;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SettingsPref;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SharedPrefUtil;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SnapshotsPref;
import com.appliedengineering.aeinstrumentcluster.R;
import com.google.android.material.switchmaterial.SwitchMaterial;

public class HomeActivity extends AppCompatActivity {

    private BackendDelegate backendDelegateObj;
    private TimestampNetworking timestampNetworking;

    // prefs
    private SettingsPref settingsPref;
    private SnapshotsPref snapshotsPref;

    private HomeTopBar homeTopBarFragment;
    private HomeContentScroll homeContentScrollFragment;

    public static MutableLiveData<Boolean> isSnapshotLoadable = new MutableLiveData<>(false);
    public static MutableLiveData<Boolean> isSnapshotLoaded = new MutableLiveData<>(false);

    // components
    private SwitchMaterial isNetworkEnabled;
    private SwitchMaterial generateDebugData;
    private Button restartNetworkButton;
    private RecyclerView snapshotRecyclerView;
    private Button takeSnapshot;
    private Button removeSnapshotsButton;
    private TextView snapshotLoadedIndicator;
    private EditText portTextBox;
    private EditText ipAddressTextBox;

    private Boolean isSystemDarkMode() {
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
        setTheme(R.style.LightTheme);
        setContentView(R.layout.home_layout);

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        // Create this frag first because other classes need it
        homeTopBarFragment = new HomeTopBar();

        // Create backend objects
        DataManager.dataManager = new DataManager();
        backendDelegateObj = new BackendDelegate(homeTopBarFragment, this);
        timestampNetworking = new TimestampNetworking(this);

        homeContentScrollFragment = new HomeContentScroll();

        // Add the fragments programmatically
        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.top_header, homeTopBarFragment)
                .commit();

        getSupportFragmentManager()
                .beginTransaction()
                .add(R.id.content_scroll, homeContentScrollFragment)
                .commit();


        // Make sure to only start execute after everything has been setup
        // execute the tasks in parallel
        backendDelegateObj.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        timestampNetworking.executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);

        // Extract all references
        restartNetworkButton = findViewById(R.id.restart_network_button);
        isNetworkEnabled = findViewById(R.id.is_network_enabled);
        generateDebugData = findViewById(R.id.generate_debug_data);
        snapshotRecyclerView = findViewById(R.id.snapshot_recycler_view);
        takeSnapshot = findViewById(R.id.take_snapshot_button);
        snapshotLoadedIndicator = findViewById(R.id.snapshot_loaded_indicator);
        removeSnapshotsButton = findViewById(R.id.remove_snapshot_button);
        ipAddressTextBox = findViewById(R.id.network_ip_address_text_box);
        portTextBox = findViewById(R.id.network_port_text_box);

        // load all prefs
        settingsPref = SharedPrefUtil.loadSettingsPreferences(this);
        snapshotsPref = SharedPrefUtil.loadSnapshotsPreferences(this);

        // Restart network button
        restartNetworkButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                backendDelegateObj.reconnect(HomeActivity.this);
                AnimationUtil.setDepressedButtonAnimation("Restart", "Restarting", restartNetworkButton);
            }
        });

        // Is network enabled switch
        isNetworkEnabled.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                updateSnapshotLoadability();
                if (b && isSnapshotLoaded.getValue()) {
                    Toast.makeText(HomeActivity.this, "Remove all loaded snapshots before starting network", Toast.LENGTH_LONG).show();
                    isNetworkEnabled.setChecked(false);
                    return;
                }
                backendDelegateObj.setNetworkEnabled(b);
            }
        });

        // Debug switch
        generateDebugData.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                updateSnapshotLoadability();
                if (isNetworkEnabled.isChecked()) {
                    generateDebugData.setChecked(false);
                    Toast.makeText(HomeActivity.this, "You must first disable the network!", Toast.LENGTH_LONG).show();
                    return;
                }
                if (b && isSnapshotLoaded.getValue()) {
                    Toast.makeText(HomeActivity.this, "Remove all loaded snapshots before starting debug data", Toast.LENGTH_LONG).show();
                    generateDebugData.setChecked(false);
                    return;
                }
                backendDelegateObj.setGenerateDebugData(b);
            }
        });

        // Set up recycler view
        SnapshotRecyclerAdapter snapshotRecyclerAdapter = new SnapshotRecyclerAdapter(this);
        snapshotRecyclerView.setLayoutManager(new LinearLayoutManager(HomeActivity.this, LinearLayoutManager.VERTICAL, false));
        snapshotRecyclerView.setAdapter(snapshotRecyclerAdapter);
        snapshotRecyclerAdapter.setData(snapshotsPref.snapshots);

        // Take snapshot button
        takeSnapshot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String serializedData = DataManager.serializeData();
                snapshotsPref.snapshots.add(serializedData);
                SharedPrefUtil.saveSnapshotsPreferences(HomeActivity.this, snapshotsPref);
                snapshotRecyclerAdapter.setData(snapshotsPref.snapshots);

            }
        });

        // snapshot loaded indicator
        isSnapshotLoaded.observe(this, new Observer<Boolean>() {
            @Override
            public void onChanged(Boolean isLoaded) {
                if (isLoaded) {
                    snapshotLoadedIndicator.setText("yes");
                } else {
                    snapshotLoadedIndicator.setText("no");
                }
            }
        });


        // Remove snapshots button
        removeSnapshotsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                DataManager.dataManager.reset(HomeActivity.this);
                isSnapshotLoaded.setValue(false);
            }
        });


        ipAddressTextBox.setText(settingsPref.ipAddress);
        ipAddressTextBox.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void afterTextChanged(Editable editable) {
                updateIpAddress(editable.toString());
            }
        });

        portTextBox.setText(settingsPref.port);
        portTextBox.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
            }

            @Override
            public void afterTextChanged(Editable editable) {
                updatePort(editable.toString());
            }
        });


    }

    private void updateSnapshotLoadability() {
        isSnapshotLoadable.setValue(!generateDebugData.isChecked() && !isNetworkEnabled.isChecked());
    }

    private void updatePort(String toString) {
        settingsPref.port = toString;
        SharedPrefUtil.saveSettingsPreferences(this, settingsPref);
    }

    private void updateIpAddress(String toString) {
        settingsPref.ipAddress = toString;
        SharedPrefUtil.saveSettingsPreferences(this, settingsPref);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

}