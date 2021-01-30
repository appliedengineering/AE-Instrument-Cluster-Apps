package com.appliedengineering.aeinstrumentcluster.Backend;

import android.net.wifi.WifiManager;

import java.net.NetworkInterface;

//https://stackoverflow.com/a/13223018/

public class multicastLockDelegate {
    private static WifiManager wifi;
    private static WifiManager.MulticastLock lock;

    private multicastLockDelegate(){}; // private constructor

    public static void init(WifiManager service){
        wifi = service;
        lock = wifi.createMulticastLock("multicastLock");
        lock.setReferenceCounted(true);
        lock.acquire();
    }

    public static void deinit(){
        if (lock != null){
            lock.release();
            lock = null;
        }
    }
}
