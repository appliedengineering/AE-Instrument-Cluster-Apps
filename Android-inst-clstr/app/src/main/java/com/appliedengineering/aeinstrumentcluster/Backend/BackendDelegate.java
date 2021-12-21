package com.appliedengineering.aeinstrumentcluster.Backend;

import android.app.Activity;
import android.os.AsyncTask;
import android.os.SystemClock;
import android.widget.TextView;

import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SettingsPref;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SharedPrefUtil;
import com.appliedengineering.aeinstrumentcluster.R;
import com.appliedengineering.aeinstrumentcluster.UI.HomeTopBar;

import org.msgpack.core.MessagePack;
import org.msgpack.core.MessageUnpacker;
import org.msgpack.value.MapValue;
import org.msgpack.value.Value;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
//import org.zeromq.EmbeddedLibraryTools;


// Class design found here: https://stackoverflow.com/a/36155334/
public class BackendDelegate extends AsyncTask<Void, Void, Void> {

    private static final int NO_MESSAGE_COUNT_THRESHOLD = 5;

    private final DataManager dataManager;
    private final HomeTopBar homeTopBar;
    private volatile boolean isRunning = true;
    private volatile boolean isNetworkEnabled = true;
    private volatile boolean generateDebugData = false;
    private Thread debugThread;


    private volatile int noMessageCount = NO_MESSAGE_COUNT_THRESHOLD;

    // options
    private volatile SettingsPref settings;


    // not used
//    private String connectionAddress = "";
//    private String connectionGroup = "";
//    private int receiveReconnect = -1;
//    private int receiveTimeout = -1;
//    private int reconnectTimeout = -1;
//    private int receiveBuffer = 60;

    // end options


    public BackendDelegate(HomeTopBar homeTopBar, Activity activity) {
        this.dataManager = DataManager.dataManager;
        this.homeTopBar = homeTopBar;
        //this.activity = activity;

        Communication.init();

        connect(activity);

        setUpDebugThread();
    }

    private void setUpDebugThread() {
        // the debug thread is a thread dedicated to debugging
        debugThread = new Thread(new Runnable() {
            @Override
            public void run() {
                while (isRunning) {
                    if (generateDebugData) {
                        if (!isNetworkEnabled) {
                            dataManager.addDebugData(generateDebugData(), System.currentTimeMillis(), homeTopBar.getActivity());
                        }
                    }
                    SystemClock.sleep(100);
                }
            }
        });
        debugThread.start();
    }

    private Map<String, Float> generateDebugData() {
        Map<String, Float> map = new HashMap<>();
        for (String key : DataManager.GRAPH_KEY_VALUES) {
            map.put(key, (float) (Math.random() * 100f));
        }
        return map;
    }

    private void connect(Activity activity) {
        settings = SharedPrefUtil.loadSettingsPreferences(activity);
        String connectionString = "tcp://" + settings.ipAddress + ":" + settings.port;
        Communication.connect(connectionString);
    }

    public void reconnect(Activity activity) {
        Communication.disconnect();
        connect(activity);
    }

    @Override
    protected void onCancelled() {
        isRunning = false;
        Communication.deinit();
    }

    @Override
    protected Void doInBackground(Void... params) {

        while (isRunning) {
            try {
                byte[] data = Communication.recv();
                if (data != null) {
                    noMessageCount = 0;
                    handleData(data);
                } else {
                    noMessageCount++;
                    LogUtil.add("No msg to be received");
                }
                updateHomeTopBar();
            } catch (ZMQException e) {
                if (!e.equals(ZMQ.Error.EAGAIN)) {
                    LogUtil.addc("Error - " + e.getMessage());
                }
            } catch (IOException e) {
                LogUtil.addc(e.getStackTrace().toString());
            }
            SystemClock.sleep(10);
        }

        return null;
    }

    private void updateHomeTopBar() {
        // show connected indicator
        String textToDisplay;
        if (noMessageCount >= NO_MESSAGE_COUNT_THRESHOLD) {
            // offline
            textToDisplay = "Status: offline";
        } else {
            // online
            textToDisplay = "Status: online";
        }
        if (!isNetworkEnabled) {
            textToDisplay = "Status: DISABLED";
        }
        if (generateDebugData) {
            textToDisplay = "Status: DEBUG";
        }

        String finalTextToDisplay = textToDisplay;
        if (homeTopBar.getActivity() != null) {
            homeTopBar.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    TextView indicator = homeTopBar.getView().findViewById(R.id.status_indicator_text);
                    indicator.setText(finalTextToDisplay);
                }
            });
        }

    }

    private void handleData(byte[] data) throws IOException {
        if (!isNetworkEnabled) return;

        LogUtil.add("Received data: " + new String(data));

        // unpack the data into readable format
        MessageUnpacker messageUnpacker = MessagePack.newDefaultUnpacker(data);
        MapValue mv = (MapValue) messageUnpacker.unpackValue();

        Map<Value, Value> map = mv.map();

        dataManager.addData(map, homeTopBar.getActivity());


    }

    public void setNetworkEnabled(boolean isEnabled) {
        isNetworkEnabled = isEnabled;
    }

    public void setGenerateDebugData(boolean generate) {
        generateDebugData = generate;
    }

}
