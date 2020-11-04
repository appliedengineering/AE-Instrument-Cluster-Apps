//
//  communication.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/20/20.
//

import Foundation
import UIKit
import SwiftyZeroMQ5

struct APiDataPack : Decodable{
    var psuMode : Int = 0;
    var throttlePercent : Int = 0;
    var dutyPercent : Int = 0;
    var pwmFrequency : Int = 0;
    var tempC : Int = 0;
    var sourceVoltage : Float = 0.0;
    var pwmCurrent : Float = 0.0;
    var powerChange : Float = 0.0;
    var voltageChange : Float = 0.0;
    var mddStatus : Bool = false;
    var ocpStatus : Bool = false;
    var ovpStatus : Bool = false;
};

var lastCommunicationError = "";

class communicationClass{
    var connectionString = "";
    var group = "";
    var context : SwiftyZeroMQ.Context?;
    var dish : SwiftyZeroMQ.Socket?;
    
    init(){
        printVersion();
        do{
            context = try SwiftyZeroMQ.Context();
        }
        catch{
            print("COMMUNICATION ERROR : CONTEXT CREATION - \(error)");
            lastCommunicationError = "Socket: " + "\(error)";
        }
    }
    
    func printVersion(){
        let (major, minor, patch, _) = SwiftyZeroMQ.version
        print("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)")
        print("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
    }
    
    func connect(connectionstr: String, connectionGroup: String, recvTimeout: Int)->Bool{
        
        connectionString = connectionstr;
        group = connectionGroup;
    
        do{
            dish = try context?.socket(.dish);
            
            try dish?.bind(connectionString);
            //try dish?.setSubscribe("telemetry");
            try dish?.joinGroup(group);
            try dish?.setRecvTimeout(Int32(recvTimeout)); // in ms
        }
        catch{
            print("COMMUNICATION error - \(error)");
            lastCommunicationError = "\(error)";
            return false;
        }
        return true;
    }
    
    func disconnect()->Bool{
        do{
            try dish?.leaveGroup(group);
            dish = nil;
            //try context?.close();
        }
        catch{
            print("COMMUNICATION error - \(error)");
            lastCommunicationError = "\(error)";
            return false;
        }
        return true;
    }
    
    func newconnection(connectionstr: String, connectionGroup: String, recvTimeout: Int)->Bool{ // when changing ports or address
        
        if (!disconnect()){
            return false;
        }
        
        if (!connect(connectionstr: connectionstr, connectionGroup: connectionGroup, recvTimeout: recvTimeout)){
            return false;
        }
        
        return true;
    }
    
    
    func checkValidProtocol(communicationProtocol: String) -> Bool{
        switch communicationProtocol {
        case "ipc":
            return SwiftyZeroMQ.has(.ipc);
        case "pgm":
            return SwiftyZeroMQ.has(.pgm);
        case "tipc":
            return SwiftyZeroMQ.has(.tipc);
        case "norm":
            return SwiftyZeroMQ.has(.norm);
        case "curve":
            return SwiftyZeroMQ.has(.curve);
        case "gssapi":
            return SwiftyZeroMQ.has(.gssapi);
        default:
            print("not valid protocol for checking")
            return false;
        }
    }
}
