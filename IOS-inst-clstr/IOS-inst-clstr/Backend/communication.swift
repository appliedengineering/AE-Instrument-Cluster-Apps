//
//  communication.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/20/20.
//

import Foundation
import UIKit
import SwiftyZeroMQ5
import Network
// ["RPM", "Torque", "Throttle (%)", "Duty (%)", "PWM Frequency", "Temperature (C)", "Source Voltage", "PWM Current", "Power Change (Δ)", "Voltage Change (Δ)"];
public struct APiDataPack : Decodable{
    var psuMode : Int = 0;
    // graphable data
    var throttlePercent : Int = 0;
    var dutyPercent : Int = 0;
    var pwmFrequency : Int = 0;
    var rpm : Float64 = 0.0;
    var torque : Float64 = 0.0;
    var tempC : Float64 = 0.0;
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
    
    internal func printVersion(){
        let (major, minor, patch, _) = SwiftyZeroMQ.version;
        print("ZeroMQ library version is \(major).\(minor) with patch level .\(patch)");
        print("SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)");
        
        errors.addErrorToBuffer(error: errorData(description: "ZeroMQ library version is \(major).\(minor) with patch level .\(patch)", timeStamp: errors.createTimestampStruct()));
        errors.addErrorToBuffer(error: errorData(description: "SwiftyZeroMQ version is \(SwiftyZeroMQ.frameworkVersion)", timeStamp: errors.createTimestampStruct()));
        
        let permissionObj = LocalNetworkPermissionService();
        permissionObj.triggerDialog();
    }
    
    public func connect(connectionstr: String, connectionGroup: String, recvReconnect: Int, recvBuffer: Int)->Bool{
        
        connectionString = connectionstr;
        group = connectionGroup;
    
        do{
            dish = try context?.socket(.dish);
            
            try dish?.bind(connectionString);
            //try dish?.setSubscribe("telemetry");
            try dish?.joinGroup(group);
            try dish?.setRecvTimeout(Int32(recvReconnect)); // in ms
            try dish?.setRecvBufferSize(Int32(recvBuffer));
        }
        catch{
            print("CONNECT COMMUNICATION error - \(error)");
            //lastCommunicationError = "\(error)";
            errors.addErrorToBuffer(error: errorData(description: "CONNECT COMMUNICATION error - \(error)", timeStamp: errors.createTimestampStruct()));
            return false;
        }
        return true;
    }
    
    public func disconnect()->Bool{
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
    
    public func newconnection(connectionstr: String, connectionGroup: String, recvReconnect: Int, recvBuffer: Int)->Bool{ // when changing ports or address
        
        if (!disconnect()){
            print("Failed disconnect but not severe error");
            errors.addErrorToBuffer(error: errorData(description: "Failed disconnect but not severe error", timeStamp: errors.createTimestampStruct()));
        }
        
        if (!connect(connectionstr: connectionstr, connectionGroup: connectionGroup, recvReconnect: recvReconnect, recvBuffer: recvBuffer)){
            return false;
        }
        
        return true;
    }
    
    
    private func checkValidProtocol(communicationProtocol: String) -> Bool{
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
    
    public func convertErrno(errorn: Int32) -> String{
        switch errorn {
        case EAGAIN:
            return "EAGAIN - Non-blocking mode was requested and no messages are available at the moment.";
        case ENOTSUP:
            return "ENOTSUP - The zmq_recv() operation is not supported by this socket type.";
        case EFSM:
            return "EFSM - The zmq_recv() operation cannot be performed on this socket at the moment due to the socket not being in the appropriate state.";
        case ETERM:
            return "ETERM - The ØMQ context associated with the specified socket was terminated.";
        case ENOTSOCK:
            return "ENOTSOCK - The provided socket was invalid.";
        case EINTR:
            return "EINTR - The operation was interrupted by delivery of a signal before a message was available.";
        case EFAULT:
            return "EFAULT - The message passed to the function was invalid.";
        default:
            return "Not valid errno code";
        }
    }
}


// IOS 14 doesn't allow the app the recieve UDP multicast but there isn't an official API to initate the prompt for these permissions. The class below grants permssion to the app by sending phony packets locally which is stupid but there isn't any other option. Apple's support has said themself that you should send out packets as a temporary workaround.
//https://stackoverflow.com/questions/63940427/ios-14-how-to-trigger-local-network-dialog-and-check-user-answer/64242745#64242745
//https://github.com/ChoadPet/DTS-request
//https://stackoverflow.com/q/63940427/6057764

class LocalNetworkPermissionService {
    
    private let port: UInt16
    private var interfaces: [String] = []
    private var connections: [NWConnection] = []
    
    
    init() {
        self.port = 12345
        self.interfaces = ipv4AddressesOfEthernetLikeInterfaces()
    }
    
    deinit {
        connections.forEach { $0.cancel() }
    }
    
    // This method try to connect to iPhone self IP Address
    func triggerDialog() {
        for interface in interfaces {
            let host = NWEndpoint.Host(interface)
            let port = NWEndpoint.Port(integerLiteral: self.port)
            let connection = NWConnection(host: host, port: port, using: .udp)
            connection.stateUpdateHandler = { [weak self, weak connection] state in
                self?.stateUpdateHandler(state, connection: connection)
            }
            connection.start(queue: .main)
            connections.append(connection)
        }
    }
    
    // MARK: Private API
    
    private func stateUpdateHandler(_ state: NWConnection.State, connection: NWConnection?) {
        switch state {
        case .waiting:
            let content = "Hello Cruel World!".data(using: .utf8)
            connection?.send(content: content, completion: .idempotent)
        default:
            break
        }
    }
    
    private func namesOfEthernetLikeInterfaces() -> [String] {
        var addrList: UnsafeMutablePointer<ifaddrs>? = nil
        let err = getifaddrs(&addrList)
        guard err == 0, let start = addrList else { return [] }
        defer { freeifaddrs(start) }
        return sequence(first: start, next: { $0.pointee.ifa_next })
            .compactMap { i -> String? in
                guard
                    let sa = i.pointee.ifa_addr,
                    sa.pointee.sa_family == AF_LINK,
                    let data = i.pointee.ifa_data?.assumingMemoryBound(to: if_data.self),
                    data.pointee.ifi_type == IFT_ETHER
                else {
                    return nil
                }
                return String(cString: i.pointee.ifa_name)
            }
    }
    
    private func ipv4AddressesOfEthernetLikeInterfaces() -> [String] {
        let interfaces = Set(namesOfEthernetLikeInterfaces())
        
        //print("Interfaces: \(interfaces)")
        var addrList: UnsafeMutablePointer<ifaddrs>? = nil
        let err = getifaddrs(&addrList)
        guard err == 0, let start = addrList else { return [] }
        defer { freeifaddrs(start) }
        return sequence(first: start, next: { $0.pointee.ifa_next })
            .compactMap { i -> String? in
                guard
                    let sa = i.pointee.ifa_addr,
                    sa.pointee.sa_family == AF_INET
                else {
                    return nil
                }
                let name = String(cString: i.pointee.ifa_name)
                guard interfaces.contains(name) else { return nil }
                var addr = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let err = getnameinfo(sa, socklen_t(sa.pointee.sa_len), &addr, socklen_t(addr.count), nil, 0, NI_NUMERICHOST | NI_NUMERICSERV)
                guard err == 0 else { return nil }
                let address = String(cString: addr)
                //print("Address: \(address)")
                return address
            }
    }
    

}
