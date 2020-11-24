package com.appliedengineering.aeinstrumentcluster;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {

    private Button buttonname;
    private TextView text;
    private boolean isOn = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        buttonname = (Button) findViewById(R.id.clickbutton);
        text = (TextView) findViewById(R.id.clicktextview);
        buttonname.setOnClickListener(this);
    }

    @Override
    public void onClick(View v){
        text.setText((isOn ? "on" : "off"));
        isOn = !isOn;
        //System.out.println("test clicked");
    }
}