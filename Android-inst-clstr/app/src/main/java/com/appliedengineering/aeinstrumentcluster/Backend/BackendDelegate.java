package com.appliedengineering.aeinstrumentcluster.Backend;

import android.os.AsyncTask;
import android.os.SystemClock;
import android.widget.TextView;

import com.appliedengineering.aeinstrumentcluster.R;
import com.appliedengineering.aeinstrumentcluster.UI.HomeTopBar;

import org.msgpack.core.MessagePack;
import org.msgpack.core.MessageUnpacker;
import org.msgpack.value.MapValue;
import org.msgpack.value.Value;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
//import org.zeromq.EmbeddedLibraryTools;


// Class design found here: https://stackoverflow.com/a/36155334/
public class BackendDelegate extends AsyncTask<Void, Void, Void>{

    private static final int NO_MESSAGE_COUNT_THRESHOLD = 5;
    private final DataManager dataManager;
    private final HomeTopBar homeTopBar;
    private volatile boolean isRunning = true;

    private volatile int noMessageCount = 0;

    // options

    // not used

//    private String protocolString = "udp";
//    private String connectionIPAddress = "";
//    private String connectionPort = "";
//    private String connectionAddress = "";
//    private String connectionGroup = "";
//    private int receiveReconnect = -1;
//    private int receiveTimeout = -1;
//    private int reconnectTimeout = -1;
//    private int receiveBuffer = 60;

    // end options


    public BackendDelegate(DataManager dataManager, HomeTopBar homeTopBar) {
        this.dataManager = dataManager;
        this.homeTopBar = homeTopBar;
        Communication.init();
        LogUtil.add("Communication setup: " + Communication.connect("tcp://192.168.137.1:5556"));
    }

    @Override
    protected void onCancelled(){
        isRunning = false;
        Communication.deinit();
    }

    @Override
    protected Void doInBackground(Void... params) {

        loadPreferences();

        while (isRunning){
            try {
                byte[] data = Communication.recv();
                if (data != null) {
                    noMessageCount = 0;
                    handleData(data);
                }
                else{
                    noMessageCount++;
                    LogUtil.add("No msg to be received");
                }
                updateHomeTopBar();
            }
            catch (ZMQException e){
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

    private void updateHomeTopBar() {
        // show connected indicator
        String textToDisplay;
        if(noMessageCount > NO_MESSAGE_COUNT_THRESHOLD) {
            // offline
            textToDisplay = "Status: offline";
        } else {
            // online
            textToDisplay = "Status: online";
        }
        if(homeTopBar.getView() != null) {
            homeTopBar.getActivity().runOnUiThread(new Runnable() {

                @Override
                public void run() {
                    TextView indicator = homeTopBar.getView().findViewById(R.id.status_indicator_text);
                    indicator.setText(textToDisplay);
                }
            });
        }
    }

    private void handleData(byte[] data) throws IOException {
        LogUtil.add("Received data: " + new String(data));

        // unpack the data into readable format
        MessageUnpacker messageUnpacker = MessagePack.newDefaultUnpacker(data);
        MapValue mv = (MapValue) messageUnpacker.unpackValue();

        Map<Value, Value> map = mv.map();

        dataManager.addData(map);

//        for (Map.Entry<Value, Value> entry : map.entrySet()) {
//            Value key = entry.getKey();
//            Value value = entry.getValue();
//            LogUtil.add(String.format("%s : %s", key.toString(), value.toString()));
//        }
    }


    // preferences
    private void loadPreferences(){

    }

    private void savePreferences(){

    }
    // end preferences

}
