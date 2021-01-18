package com.appliedengineering.aeinstrumentcluster.Backend;
import org.zeromq.ZMQ;
import org.zeromq.ZMQException;

public final class communication {

    private static ZMQ.Context ctx;
    public static ZMQ.Socket dish = null;
    private static String connectionString = "";
    private static String group = "";

    private communication(){} // private constructor

    public static void init(){
        //ctx = ZMQ.context(1); // only need 1 io thread
        ctx = ZMQ.context(1);
        printVersion();
    }

    public static void deinit(){
        //dish.close();
        dish.close();
        ctx.close();
        //ctx.close();
    }

    protected static void printVersion(){
        //System.out.println("printing");
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
            System.out.println(communication.convertErrno(e.getErrorCode()));
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
       // return ZMQ.Error.findByCode(errorn).getMessage();
        return "";
    }

}
