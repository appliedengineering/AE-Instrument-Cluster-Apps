package com.appliedengineering.aeinstrumentcluster.Backend;

import android.os.AsyncTask;
import android.os.SystemClock;

import org.msgpack.core.MessagePack;
import org.msgpack.core.MessageUnpacker;
import org.msgpack.value.MapValue;
import org.msgpack.value.Value;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.io.IOException;
import java.util.Map;
//import org.zeromq.EmbeddedLibraryTools;


// Class design found here: https://stackoverflow.com/a/36155334/
public class BackendDelegate extends AsyncTask<Void, Void, Void>{

    private volatile boolean isRunning = true;

    // options

    private String protocolString = "udp";
    private String connectionIPAddress = "";
    private String connectionPort = "";
    private String connectionAddress = "";
    private String connectionGroup = "";
    private int receiveReconnect = -1;
    private int receiveTimeout = -1;
    private int reconnectTimeout = -1;
    private int receiveBuffer = 60;

    // end options

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
                    LogUtil.add("Received data: " + new String(data));
                    MessageUnpacker messageUnpacker = MessagePack.newDefaultUnpacker(data);
                    MapValue mv = (MapValue) messageUnpacker.unpackValue();

                    Map<Value, Value> map = mv.map();

                    for (Map.Entry<Value, Value> entry : map.entrySet()) {
                        Value key = entry.getKey();
                        Value value = entry.getValue();
                        LogUtil.add(String.format("%s : %s", key.toString(), value.toString()));
                    }
                }
                else{
                    LogUtil.add("No msg to be received");
                }
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

    public BackendDelegate(){

        Communication.init();
        LogUtil.add("Communication setup: " + Communication.connect("tcp://169.254.200.250:5556"));
    }

    // preferences
    private void loadPreferences(){

    }

    private void savePreferences(){

    }
    // end preferences

}
