//
//  localbuffer.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/8/20.
//

import Foundation
import UIKit
import Charts

class dataManager{
    var startUnixEpoch : Double = -1;
    
    static let obj = dataManager();
    
    let unixEpochPrecision : Double = 1000;
    
    private init(){
        startUnixEpoch = Date().timeIntervalSince1970;
        print("Current UNIX EPOCH = \(startUnixEpoch)");
    }
    
    func updateWithNewData(data: APiDataPack){
        let currentUnixEpoch = Date().timeIntervalSince1970;
        //print("data recieved at - \(currentUnixEpoch)");
        
        //buffer.append(convertRawData(data: data, currentUnixEpoch: currentUnixEpoch));
        // call func to update ui
        let currentData = convertRawData(data: data, currentUnixEpoch: currentUnixEpoch);
        for i in 0..<graphs.numOfGraphs{
            // print("calling - \(i) - data - \(currentData[i])")
            if (!graphs.updateGraph(with: i, point: currentData[i])){
                print("Failed to add data point at graph with index \(i) : Timestamp = \(currentUnixEpoch)");
            }
        }
        // TODO: call extra func here to mainview to update data that doesn't need a graph
        //print("new size of array after this iteration : \(graphs.graphViews[0].data!.dataSets[0].entryCount)")
        
    }
  
    private func convertRawData(data: APiDataPack, currentUnixEpoch: Double)->[ChartDataEntry]{ // one [ChartDataEntry] is one recieved APiDataPack with (x: time, y: data point)
        // data point order is determined by graphName in graphManager
        let timeDiff = Int64((currentUnixEpoch * unixEpochPrecision) - (startUnixEpoch * unixEpochPrecision));
        var output = Array(repeating: ChartDataEntry(), count: graphs.numOfGraphs);
        
        for i in 0..<graphs.numOfGraphs{
            output[i] = ChartDataEntry(x: Double(timeDiff), y: specificDataAttribute(with: i, data: data));
        }
        
        return output;
    }
    
    // ["RPM", "Torque", "Throttle (%)", "Duty (%)", "PWM Frequency", "Temperature (C)", "Source Voltage", "PWM Current", "Power Change (Δ)", "Voltage Change (Δ)"];
    
    public func specificDataAttribute(with index: Int, data: APiDataPack) -> Float64{ // will convert ints to floats as well
        switch index{
        case 0:
            return data.RPM;
        case 1:
            return data.Torque;
        case 2:
            return Float64(data.throttlePercent);
        case 3:
            return Float64(data.dutyPercent);
        case 4:
            return Float64(data.pwmFrequency);
        case 5:
            return Float64(data.tempC);
        case 6:
            return data.sourceVoltage;
        case 7:
            return data.pwmCurrent;
        case 8:
            return data.powerChange;
        case 9:
            return data.voltageChange;
        default:
            return 0;
        }
    }
    
    func clearData(){
        //buffer.removeAll();
    }
    
}
