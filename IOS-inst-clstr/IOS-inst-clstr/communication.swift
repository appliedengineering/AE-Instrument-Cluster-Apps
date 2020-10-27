//
//  communication.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/20/20.
//

import Foundation
import UIKit
import SwiftyZeroMQ5

class communicationClass{
    var connectionString = "";
    var context : SwiftyZeroMQ.Context?;
    var subscriber : SwiftyZeroMQ.Socket?;
    
    func setup(connectionstr: String, communicationProtocol: String)->Bool{
        let (major, minor, patch, versionString) = SwiftyZeroMQ.version
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
            subscriber = try context?.socket(.dish);
            try subscriber?.bind("udp://231.0.0.1:5555");
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
