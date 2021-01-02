package com.appliedengineering.aeinstrumentcluster.Backend;
import org.zeromq.ZMQ;
import org.zeromq.SocketType;
import org.zeromq.ZMQException;

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
        System.out.println(ZMQ.getFullVersion());
    }

    public static boolean connect(String connectionStr, String connectionGroup, int recvReconnect, int recvBuffer){
        connectionString = connectionStr;
        group = connectionGroup;
        try {
            dish = ctx.socket(SocketType.DISH);
            dish.bind(connectionString);
            dish.join(group);
            dish.setReceiveTimeOut(recvReconnect);
            dish.setReceiveBufferSize(recvBuffer);
        }catch (ZMQException e){
            System.out.println("Connect error V");
            System.out.println(communication.convertErrno(e.getErrorCode()));
            return false;
        }
        return true;
    }

    public static boolean disconnect(){
        try{
            dish.leave(group);
            dish.disconnect(connectionString);
            dish.close();
            dish = null;
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
