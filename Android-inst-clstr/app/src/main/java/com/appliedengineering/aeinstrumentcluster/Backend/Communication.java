package com.appliedengineering.aeinstrumentcluster.Backend;

import android.util.Log;

import org.msgpack.core.MessageBufferPacker;
import org.msgpack.core.MessagePack;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

public final class Communication {

    private static ZMQ.Context ctx, ctxTime;
    public static ZMQ.Socket sub = null;
    public static ZMQ.Socket timeSocket = null;
    private static String connectionString = "";
    private static String timeConnectionString = "";

    private Communication() {
    } // private constructor

    public static void init() {
        ctx = ZMQ.context(1); // only need 1 io thread
        ctxTime = ZMQ.context(1); // only need 1 io thread
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
            timeSocket = ctxTime.socket(ZMQ.REQ);
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


    public static boolean sendTimestamp(double data) throws ZMQException {
        // pack the data

        LogUtil.add(data+" is the time");

        MessageBufferPacker packer = MessagePack.newDefaultBufferPacker();
        try {
            packer.packDouble(data/1000d);
            timeSocket.send(packer.toByteArray());
            packer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        // timeSocket.sendTime();
        LogUtil.add("Receiving timestamp from raspberry pi");
        byte[] buffer = timeSocket.recv();
        LogUtil.add("Received timestamp from raspberry pi " + new String(buffer));
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
