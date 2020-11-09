//
//  localbuffer.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/8/20.
//

import Foundation
import UIKit
import Deque
import Charts


struct dataBufferDataSet {
    var dataPack = APiDataPack();
    var unixEpochDifference : Int64 = -1;
}

class dataBuffer{
    var startUnixEpoch : Int64 = -1;
    var buffer = Deque<dataBufferDataSet>();
    let maxSize = 100;
    
    init(){
        startUnixEpoch = Int64(Date().timeIntervalSince1970);
        print("Current UNIX EPOCH = \(startUnixEpoch)");
    }
    
    func updateWithNewData(data: APiDataPack){
        
        let currentUnixEpoch = Int64(Date().timeIntervalSince1970);
        //print("data recieved at - \(currentUnixEpoch)");
        
        buffer.append(convertRawData(data: data, currentUnixEpoch: currentUnixEpoch));
        if (buffer.count > maxSize){
            buffer.popFirst();
        }
        
        // call func to update ui
    
        
        
    }
  
    func convertRawData(data: APiDataPack, currentUnixEpoch: Int64)->dataBufferDataSet{
        return dataBufferDataSet(dataPack: data, unixEpochDifference: Int64(currentUnixEpoch - startUnixEpoch));
    }
    
    func clearData(){
        buffer.removeAll();
    }
    
    
}
