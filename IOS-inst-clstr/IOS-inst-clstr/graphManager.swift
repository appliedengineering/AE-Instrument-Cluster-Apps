//
//  graphManager.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/8/20.
//

import Foundation
import UIKit
import Charts

// https://medium.com/@OsianSmith/creating-a-line-chart-in-swift-3-and-ios-10-2f647c95392e

let numOfGraphs = 10;

class graphManager{ // all funcs must be called from
    let graphNameArray = ["RPM", "Torque", "Throttle (%)", "Duty (%)", "PWM Frequency", "Temperature (C)", "Source Voltage", "PWM Current", "Power Change (Δ)", "Voltage Change (Δ)"];
    var graphViews = [LineChartView](); // This should be populated with chart views after first render

    func updateAll(data: [[ChartDataEntry]]){ // hierarchy of this 2d array is each outer array that contains a [ChartDataEntry] is a graph, in which you correlate graphName with this outer array, so for any graph i, the name of the graph is graphNameArray[i] and the array of data points is data[i] which gives you a [ChartDataEntry]
        
        //print(data)
        
        for i in 0..<numOfGraphs{ // # of numOfGraphs
            //print("i - \(i) = \(data[i])")
            let line = LineChartDataSet(entries: data[i], label: graphNameArray[i]);
            
            // set attributes of line here
            
            
            
            // end set attributes
            
            updateGraph(with: i, line: line);
        }
        
    }
    
    func updateGraph(with index: Int,  line: LineChartDataSet){
        let data = LineChartData();
        data.addDataSet(line);
        graphViews[index].data = data;
    }
    
    
}
