package com.appliedengineering.aeinstrumentcluster.Backend;

import com.appliedengineering.aeinstrumentcluster.Backend.multicastLockDelegate;

import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

import java.nio.ByteBuffer;

public final class communication {

    private static ZMQ.Context ctx;
    public static ZMQ.Socket dish = null;
    private static String connectionString = "";
    private static String group = "";

    private communication(){} // private constructor

    public static void init(){
        ctx = ZMQ.context(1); // only need 1 io thread
        printVersion();
    }

    public static void deinit(){
        dish.close();
        ctx.close();
    }

    protected static void printVersion(){
        System.out.println("ZMQ Version: " + ZMQ.getVersionString());
    }

    public static boolean connect(String connectionStr, String connectionGroup, int recvReconnect, int recvBuffer){
        connectionString = connectionStr;
        group = connectionGroup;
        try {
            dish = ctx.socket(ZMQ.DISH);
            dish.bind(connectionString);
            dish.join(group); // TODO: Implement join function in JZMQ
            dish.setReceiveTimeOut(recvReconnect);
            dish.setReceiveBufferSize(recvBuffer);
        }catch (ZMQException e){
            System.out.println("Connect error V");
            System.out.println(e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean disconnect(){
        try{
            dish.leave(group);
            dish.unbind(connectionString);
            dish.close();
            dish = null;
        }catch (ZMQException e){
            System.out.println(e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean newConnection(String connectionStr, String connectionGroup, int recvReconnect, int recvBuffer){
        if (!disconnect()){
            System.out.println("Failed disconnect but not severe error");
        }

        if (!connect(connectionStr, connectionGroup, recvReconnect, recvBuffer)){
            return false;
        }
        return true;
    }

    public static byte[] recv() throws ZMQException{
        /*ByteBuffer buf = ByteBuffer.allocateDirect(100);
        int size = dish.recvZeroCopy(buf, buf.remaining(), 0);
        buf.flip();
        if (size >= 0) {
            byte[] b = new byte[size];
            buf.get(b);
            return b;
        }
        else{
            System.out.println("bytes recv less than 0 = " + size);
        }
        return new byte[0];*/
        byte[] buffer = new byte[0];
        try{
            buffer = dish.recv();
        }
        catch (ZMQException e){
            System.out.println(e.getMessage());
        }
        return buffer;
    }

    public static String convertErrno(int errorn){
       // return ZMQ.Error.findByCode(errorn).getMessage();
        return "";
    }

}
