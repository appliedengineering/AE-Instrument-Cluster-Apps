package com.appliedengineering.aeinstrumentcluster.communication;
import org.zeromq.ZMQ;
import org.zeromq.SocketType;

public final class communication {

    private static ZMQ.Context ctx;
    private static ZMQ.Socket dish;

    private communication(){} // private constructor

    public static void init(){
        ctx = ZMQ.context(1); // only need 1 io thread
        dish = ctx.socket(SocketType.DISH);
    }

    public static void deinit(){
        dish.close();
        ctx.close();
    }

    public static boolean connect(){
        
        return true;
    }

}
