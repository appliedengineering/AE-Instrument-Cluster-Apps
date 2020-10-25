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
    
    init(connectionstr: String, communicationProtocol: String){
        let (major, minor, patch, versionString) = SwiftyZeroMQ.version
        print("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)")
        print("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
        connectionString = connectionstr;
        print("protocol \(communicationProtocol) is " + (checkValidProtocol(communicationProtocol: communicationProtocol) ? "supported" : "not supported"));
        let protocols = ["ipc", "pgm", "epgm", "tipc", "norm", "curve", "gssapi"]
        for i in protocols{
            print("\(i) - \(checkValidProtocol(communicationProtocol: i))")
        }
    
        do{
            context = try SwiftyZeroMQ.Context();
            subscriber = try context?.socket(.subscribe);
            try subscriber?.connect(connectionstr);
        }
        catch{
            print("error - \(error)");
            //return;
        }
        
    }
    func checkValidProtocol(communicationProtocol: String) -> Bool{
        switch communicationProtocol {
        case "ipc":
            return SwiftyZeroMQ.has(.ipc);
        case "pgm":
            return SwiftyZeroMQ.has(.pgm);
        case "epgm":
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
            print("not valid protocol")
            return false;
        }
    }
    func start(){
        print("start")
    }
}
