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
    var psuMode : Int = 2;
    var throttlePercent : Int = 0;
    var dutyPercent : Int = 0;
    var pwmFrequency : Int = 20000;
    var tempC : Int = 0;
    var sourceVoltage : Float = 0.0;
    var pwmCurrent : Float = 0.0;
    var powerChange : Float = 0.0;
    var voltageChange : Float = 0.0;
    var mddStatus : Bool = false;
    var ocpStatus : Bool = false;
    var ovpStatus : Bool = false;
};


class communicationClass{
    var connectionString = "";
    var context : SwiftyZeroMQ.Context?;
    var dish : SwiftyZeroMQ.Socket?;
    
    func setup(connectionstr: String, recvTimeout: Int)->Bool{
        let (major, minor, patch, _) = SwiftyZeroMQ.version
        print("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)")
        print("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
        
        connectionString = connectionstr;
        
        /*print("protocol \(communicationProtocol) is " + (checkValidProtocol(communicationProtocol: communicationProtocol) ? "supported" : "not supported"));
        let protocols = ["ipc", "pgm", "tipc", "norm", "curve", "gssapi"]
        for i in protocols{
            print("\(i) - \(checkValidProtocol(communicationProtocol: i))")
        }*/
    
        do{
            context = try SwiftyZeroMQ.Context();
            dish = try context?.socket(.dish);
            try dish?.bind(connectionString);
            //try dish?.setSubscribe("telemetry");
            try dish?.joinGroup("telemetry");
            try dish?.setRecvTimeout(Int32(recvTimeout)); // in ms
        }
        catch{
            print("COMMUNICATION error - \(error)");
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
    func start(){
        print("start")
    }
}
