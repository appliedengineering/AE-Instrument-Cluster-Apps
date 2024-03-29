package com.appliedengineering.aeinstrumentcluster.Backend;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.Build;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.RequiresApi;

import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SettingsPref;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SharedPrefUtil;

import org.msgpack.core.MessagePack;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.TemporalField;
import java.util.ArrayList;
import java.util.List;

public class TimestampNetworking extends AsyncTask<Void, Void, Void> {

    private volatile boolean isRunning = true;

    private volatile List<String> pendingCommands = new ArrayList<>();
    private volatile boolean wasTimestampUpdateSuccessful = false;

    public void addCommand() {
        pendingCommands.add("send_time");
    }

    public TimestampNetworking(Activity activity) {
        SettingsPref settings = SharedPrefUtil.loadSettingsPreferences(activity);
        String connectionString = "tcp://" + settings.ipAddress + ":" + "55561";
        LogUtil.add("Connecting to timestamp networking");
        Communication.connectToTimestampSocket(connectionString);
        LogUtil.add("Connected to timestamp networking");
    }

    @Override
    protected void onCancelled() {
        isRunning = false;
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected Void doInBackground(Void... params) {
        LogUtil.add("Start handling timestamp requests");
        while (isRunning) {
            try {
                if(pendingCommands.isEmpty()) {
                    // if(wasTimestampUpdateSuccessful) {
                        LogUtil.add("Sending timestamp to raspberry pi");
                        wasTimestampUpdateSuccessful = Communication.sendTimestamp(System.currentTimeMillis());
                        LogUtil.add("Sent timestamp to raspberry pi");
                    // }
                } else {
                    // Communication.sendCommand(pendingCommands.remove(0));
                }
//                LogUtil.add("Receiving timestamp from raspberry pi");
//                byte[] data = Communication.recvTimestamp();
//                LogUtil.add("Received timestamp from raspberry pi");
//                if (data != null) {
//                    handleData(data);
//                }
            } catch (ZMQException e) {
                if (!e.equals(ZMQ.Error.EAGAIN)) {
                    LogUtil.addc("Error - " + e.getMessage());
                }
            }
//            } catch (IOException e) {
//                LogUtil.addc(e.getStackTrace().toString());
//            }
            SystemClock.sleep(1000);

        }
        Communication.disconnectTimeSocket();
        return null;
    }


    private void handleData(byte[] data) throws IOException {
        LogUtil.add("Timestamp updated: " + MessagePack.newDefaultUnpacker(data).toString());
    }

}
