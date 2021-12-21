package com.appliedengineering.aeinstrumentcluster.Backend;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.SystemClock;

import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SettingsPref;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SharedPrefUtil;

import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.io.IOException;

public class TimestampNetworking extends AsyncTask<Void, Void, Void> {

    private volatile boolean isRunning = true;

    public TimestampNetworking(Activity activity) {
        SettingsPref settings = SharedPrefUtil.loadSettingsPreferences(activity);
        String connectionString = "tcp://" + settings.ipAddress + ":55561";
        Communication.connectToTimestampSocket(connectionString);
    }

    @Override
    protected void onCancelled() {
        isRunning = false;
    }

    @Override
    protected Void doInBackground(Void... params) {
        while (isRunning) {
            try {

                Communication.sendTimestamp(Long.toString(System.currentTimeMillis()).getBytes());
                byte[] data = Communication.recvTimestamp();
                if (data != null) {
                    handleData(data);
                }
            } catch (ZMQException e) {
                if (!e.equals(ZMQ.Error.EAGAIN)) {
                    LogUtil.addc("Error - " + e.getMessage());
                }
            } catch (IOException e) {
                LogUtil.addc(e.getStackTrace().toString());
            }
            SystemClock.sleep(1000);

        }
        return null;
    }


    private void handleData(byte[] data) throws IOException {
        LogUtil.add("Timestamp updated: " + new String(data));
    }

}
