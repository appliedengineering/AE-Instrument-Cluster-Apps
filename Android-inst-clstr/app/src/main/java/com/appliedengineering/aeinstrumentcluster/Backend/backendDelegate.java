package com.appliedengineering.aeinstrumentcluster.Backend;

import android.os.AsyncTask;
import android.os.SystemClock;

import com.appliedengineering.aeinstrumentcluster.Backend.*;

import org.zeromq.ZMQ;
import org.zeromq.ZMQException;
import org.zeromq.EmbeddedLibraryTools;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

// Class design found here: https://stackoverflow.com/a/36155334/
public class backendDelegate extends AsyncTask<Void, Void, Void>{

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
        communication.deinit();
    }

    @Override
    protected Void doInBackground(Void... params) {

        loadPreferences();

        while (isRunning){
            try {
                byte[] data = communication.recv();
                if (data != null) {
                    log.add("Received data: " + new String(data));
                }
                else{
                    log.add("No msg to be received");
                }
            }
            catch (ZMQException e){
                if (!e.equals(ZMQ.Error.EAGAIN)) {
                    log.addc("Error - " + e.getMessage());
                }
            }
            SystemClock.sleep(1000);
        }

        return null;
    }

    public backendDelegate(){
        communication.init();
        log.add("Communication setup: " + communication.connect("tcp://192.168.1.8:1234"));
    }

    // preferences
    private void loadPreferences(){

    }

    private void savePreferences(){

    }
    // end preferences

}
