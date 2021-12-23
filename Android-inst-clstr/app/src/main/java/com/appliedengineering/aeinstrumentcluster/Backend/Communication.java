package com.appliedengineering.aeinstrumentcluster.Backend;

import android.util.Log;

import org.msgpack.core.MessageBufferPacker;
import org.msgpack.core.MessagePack;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.io.IOException;

public final class Communication {

    private static ZMQ.Context ctx;
    public static ZMQ.Socket sub = null;
    public static ZMQ.Socket timeSocket = null;
    private static String connectionString = "";
    private static String timeConnectionString = "";

    private Communication() {
    } // private constructor

    public static void init() {
        ctx = ZMQ.context(1); // only need 1 io thread
        printVersion();
    }

    public static void deinit() {
        sub.close();
        timeSocket.close();
        ctx.close();
    }

    protected static void printVersion() {
        LogUtil.add("ZMQ Version: " + ZMQ.getVersionString());
    }

    public static boolean connect(String connectionStr) {
        connectionString = connectionStr;
        try {
            sub = ctx.socket(ZMQ.SUB);
            sub.connect(connectionString);
            sub.subscribe("".getBytes());
        } catch (ZMQException e) {
            LogUtil.addc("Connect error: " + e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean connectToTimestampSocket(String connectionString) {
        timeConnectionString = connectionString;
        try {
            timeSocket = ctx.socket(ZMQ.REQ);
            timeSocket.connect(timeConnectionString);
        } catch (ZMQException e) {
            LogUtil.addc("Connect error: " + e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean disconnectTimeSocket() {
        try {
            timeSocket.disconnect(timeConnectionString);
            timeSocket.close();
            timeSocket = null;
        } catch (ZMQException e) {
            Log.d("communication", e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean disconnect() {
        try {
            sub.disconnect(connectionString);
            sub.close();
            sub = null;
        } catch (ZMQException e) {
            Log.d("communication", e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean newConnection(String connectionStr) {
        if (!disconnect()) {
            LogUtil.add("Failed disconnect but not severe error");
        }

        return connect(connectionStr);
    }

    public static byte[] recv() throws ZMQException {
        byte[] buffer = null;
        try {
            buffer = sub.recv(ZMQ.NOBLOCK);
        } catch (ZMQException e) {
            LogUtil.add("Recv Error: " + e.getMessage());
        }
        return buffer;
    }


    public static boolean sendTimestamp(long data) throws ZMQException {
        // pack the data
        MessageBufferPacker packer = MessagePack.newDefaultBufferPacker();
        try {
            packer.packTimestamp(data);
            timeSocket.send(packer.toByteArray());
            packer.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return true;
    }

    public static byte[] recvTimestamp() throws ZMQException {
        byte[] buffer = null;
        try {
            buffer = timeSocket.recv();
        } catch (ZMQException e) {
            LogUtil.add("Recv Error: " + e.getMessage());
        }
        return buffer;
    }

    public static void sendCommand(String string) {
        // TODO: implement
    }
}
