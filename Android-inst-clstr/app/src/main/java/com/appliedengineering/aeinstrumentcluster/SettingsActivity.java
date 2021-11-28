package com.appliedengineering.aeinstrumentcluster;

import androidx.appcompat.app.AppCompatActivity;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

public class SettingsActivity extends AppCompatActivity implements View.OnClickListener{

    private EditText ipAddressTextBox;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setTheme(R.style.LightTheme);
        setContentView(R.layout.activity_settings);

        // Control some settings
        Button savedChangesButton = findViewById(R.id.save_changes_button);
        ipAddressTextBox = findViewById(R.id.ip_address_edit_text);

        // Restore values
        SharedPreferences settings = getSharedPreferences("SettingsInfo", 0);
        String ipAddress = settings.getString("ipAddress", "192.168.137.1");
        ipAddressTextBox.setText(ipAddress);
        savedChangesButton.setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        // update ip address
        SharedPreferences settings = getSharedPreferences("SettingsInfo", 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("ipAddress", ipAddressTextBox.getText().toString());
        editor.commit();

        finish();
    }
}