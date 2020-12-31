package com.appliedengineering.aeinstrumentcluster.Backend;
import org.zeromq.ZMQ;
import org.zeromq.SocketType;
import org.zeromq.ZMQException;

public final class communication {

    private static ZMQ.Context ctx;
    private static ZMQ.Socket dish;
    private static String connectionString = "";
    private static String group = "";

    private communication(){} // private constructor

    public static void init(){
        ctx = ZMQ.context(1); // only need 1 io thread
        dish = ctx.socket(SocketType.DISH);
    }

    public static void deinit(){
        dish.close();
        ctx.close();
    }

    public static boolean connect(String connectionStr, String connectionGroup, int recvReconnect, int recvBuffer){
        connectionString = connectionStr;
        group = connectionGroup;
        try {
            dish.bind(connectionString);
            dish.join(group);
            dish.setReceiveTimeOut(recvReconnect);
            dish.setReceiveBufferSize(recvBuffer);
        }catch (Exception e){
            System.out.println(e.getMessage());
            return false;
        }
        return true;
    }

    public static boolean disconnect(){
        try{
            dish.leave(group);
            dish.disconnect(connectionString);
        }catch (Exception e){
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

    public static String convertErrno(int errorn){
        return ZMQ.Error.findByCode(errorn).getMessage();
    }

}
