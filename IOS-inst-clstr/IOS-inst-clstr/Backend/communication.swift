//
//  communication.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/20/20.
//

import Foundation
import UIKit
import SwiftyZeroMQ5
// ["RPM", "Torque", "Throttle (%)", "Duty (%)", "PWM Frequency", "Temperature (C)", "Source Voltage", "PWM Current", "Power Change (Δ)", "Voltage Change (Δ)"];
public struct APiDataPack : Decodable{
    var psuMode : Int = 0;
    // graphable data
    var rpm : Float64 = 0.0;
    var torque : Float64 = 0.0;
    var throttlePercent : Int = 0;
    var dutyPercent : Int = 0;
    var pwmFrequency : Int = 0;
    var tempC : Int = 0;
    var sourceVoltage : Float64 = 0.0;
    var pwmCurrent : Float64 = 0.0;
    var powerChange : Float64 = 0.0;
    var voltageChange : Float64 = 0.0;
    // graphable data
    var mddStatus : Bool = false;
    var ocpStatus : Bool = false;
    var ovpStatus : Bool = false;
};


class communicationClass{
    //var lastCommunicationError = "";
    var connectionString = "";
    var group = "";
    var context : SwiftyZeroMQ.Context?;
    var dish : SwiftyZeroMQ.Socket?;
    
    static let obj = communicationClass(); // singleton pattern

    private init(){ // singleton pattern
        printVersion();
        do{
            context = try SwiftyZeroMQ.Context();
        }
        catch{
            print("COMMUNICATION ERROR : CONTEXT CREATION - \(error)");
            errors.addErrorToBuffer(error: errorData(description: "COMMUNICATION ERROR : CONTEXT CREATION - \(error)", timeStamp: errors.createTimestampStruct()));
            //lastCommunicationError = "Socket: " + "\(error)";
        }
    }
    
    func printVersion(){
        let (major, minor, patch, _) = SwiftyZeroMQ.version
        print("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)")
        print("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
    }
    
    func connect(connectionstr: String, connectionGroup: String, recvReconnect: Int)->Bool{
        
        connectionString = connectionstr;
        group = connectionGroup;
    
        do{
            dish = try context?.socket(.dish);
            
            try dish?.bind(connectionString);
            //try dish?.setSubscribe("telemetry");
            try dish?.joinGroup(group);
            try dish?.setRecvTimeout(Int32(recvReconnect)); // in ms
        }
        catch{
            print("CONNECT COMMUNICATION error - \(error)");
            //lastCommunicationError = "\(error)";
            errors.addErrorToBuffer(error: errorData(description: "CONNECT COMMUNICATION error - \(error)", timeStamp: errors.createTimestampStruct()));
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
            print("DISCONNECT COMMUNICATION error - \(error)");
            //lastCommunicationError = "\(error)";
            errors.addErrorToBuffer(error: errorData(description: "DISCONNECT COMMUNICATION error - \(error)", timeStamp: errors.createTimestampStruct()));
            return false;
        }
        return true;
    }
    
    func newconnection(connectionstr: String, connectionGroup: String, recvReconnect: Int)->Bool{ // when changing ports or address
        
        if (!disconnect()){
            print("Failed disconnect but not severe error");
            errors.addErrorToBuffer(error: errorData(description: "Failed disconnect but not severe error", timeStamp: errors.createTimestampStruct()));
        }
        
        if (!connect(connectionstr: connectionstr, connectionGroup: connectionGroup, recvReconnect: recvReconnect)){
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
