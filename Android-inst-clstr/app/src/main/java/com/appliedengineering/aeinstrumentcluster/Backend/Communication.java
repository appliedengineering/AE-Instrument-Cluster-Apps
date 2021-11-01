package com.appliedengineering.aeinstrumentcluster.Backend;

import android.util.Log;

import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

public final class Communication {

    private static ZMQ.Context ctx;
    public static ZMQ.Socket sub = null;
    private static String connectionString = "";

    private Communication(){} // private constructor

    public static void init(){
        ctx = ZMQ.context(1); // only need 1 io thread
        printVersion();
    }

    public static void deinit(){
        sub.close();
        ctx.close();
    }

    protected static void printVersion(){
        LogUtil.add("ZMQ Version: " + ZMQ.getVersionString());
    }

    public static boolean connect(String connectionStr){
        connectionString = connectionStr;
        try {
            sub = ctx.socket(ZMQ.SUB);
            sub.connect(connectionString);
            sub.subscribe("".getBytes());
        }catch (ZMQException e){
            LogUtil.addc("Connect error: " + e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean disconnect(){
        try{
            sub.disconnect(connectionString);
            sub.close();
            sub = null;
        }catch (ZMQException e){
            Log.d("communication", e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean newConnection(String connectionStr){
        if (!disconnect()){
            LogUtil.add("Failed disconnect but not severe error");
        }

        if (!connect(connectionStr)){
            return false;
        }
        return true;
    }

    public static byte[] recv() throws ZMQException{
        byte[] buffer = null;
        try{
            buffer = sub.recv(ZMQ.NOBLOCK);
        }
        catch (ZMQException e){
            LogUtil.add( "Recv Error: " + e.getMessage());
        }
        return buffer;
    }

}
