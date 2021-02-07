package com.appliedengineering.aeinstrumentcluster.Backend;

import org.zeromq.ZMQ;
import org.zeromq.ZMQException;
import com.appliedengineering.aeinstrumentcluster.Backend.*;

public final class communication {

    private static ZMQ.Context ctx;
    public static ZMQ.Socket sub = null;
    private static String connectionString = "";

    private communication(){} // private constructor

    public static void init(){
        ctx = ZMQ.context(1); // only need 1 io thread
        printVersion();
    }

    public static void deinit(){
        sub.close();
        ctx.close();
    }

    protected static void printVersion(){
        log.add("ZMQ Version: " + ZMQ.getVersionString());
    }

    public static boolean connect(String connectionStr){
        connectionString = connectionStr;
        try {
            sub = ctx.socket(ZMQ.SUB);
            sub.connect(connectionString);
            sub.subscribe("".getBytes());
        }catch (ZMQException e){
            log.addc("Connect error: " + e.getMessage());
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
            System.out.println(e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean newConnection(String connectionStr){
        if (!disconnect()){
            log.add("Failed disconnect but not severe error");
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
            log.add( "Recv Error: " + e.getMessage());
        }
        return buffer;
    }

}
