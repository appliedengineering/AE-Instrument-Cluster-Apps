package com.appliedengineering.aeinstrumentcluster.Backend;

import android.net.wifi.WifiManager;

//https://stackoverflow.com/a/13223018/

public class multicastLockDelegate {
    private static WifiManager wifi;
    private static WifiManager.MulticastLock lock;
    private static boolean isLocked = false;

    private multicastLockDelegate(){}; // private constructor

    public static void init(WifiManager service){
        wifi = service;
        isLocked = true;
        lock = wifi.createMulticastLock("multicastLock");
        lock.setReferenceCounted(true);
        lock.acquire();
    }

    public static void deinit(){
        if (isLocked && lock != null){
            lock.release();
            lock = null;
            isLocked = false;
        }
    }
}
