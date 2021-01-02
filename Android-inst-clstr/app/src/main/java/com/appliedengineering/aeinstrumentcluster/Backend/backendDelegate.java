package com.appliedengineering.aeinstrumentcluster.Backend;

import android.os.AsyncTask;
import android.os.SystemClock;

import com.appliedengineering.aeinstrumentcluster.Backend.*;

// Class design found here: https://stackoverflow.com/a/36155334/
public class backendDelegate extends AsyncTask {

    private volatile boolean isRunning = true;

    @Override
    protected void onCancelled(){
        isRunning = false;
        communication.deinit();
    }

    @Override
    protected Void doInBackground(Object[] objects) {
        communication.init();
        while (isRunning){

            System.out.println("Iteration");
            SystemClock.sleep(1000);

        }
        return null;
    }
}
