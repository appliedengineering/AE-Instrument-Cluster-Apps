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


class graphManager{ // all funcs must be called from
    let numOfGraphs = 10;
    let graphColorArray = [rgb(r: 63,g: 81,b: 181), rgb(r: 0,g: 150,b: 136), rgb(r: 76,g: 175,b: 80), rgb(r: 139,g: 195,b: 74), rgb(r: 255,g: 235,b: 59), rgb(r: 255,g: 152,b: 0), rgb(r: 255,g: 87,b: 34), rgb(r: 244,g: 67,b: 54), rgb(r: 233,g: 30,b: 99), rgb(r: 156,g: 39,b: 176)];
    let graphNameArray = ["RPM", "Torque", "Throttle (%)", "Duty (%)", "PWM Frequency", "Temperature (C)", "Source Voltage", "PWM Current", "Power Change (Δ)", "Voltage Change (Δ)"];
    var graphViews = [LineChartView](); // This should be populated with chart views after first render
    
    static let obj = graphManager();
    
    private init(){}
    
    public func updateGraph(with index: Int, point: ChartDataEntry) -> Bool{
        //print(type(of: graphViews[index].data!.dataSets[0]))
        //print("add point - \(point)")
        let result = graphViews[index].data!.dataSets[0].addEntry(point);
        if (result){
            
            // https://stackoverflow.com/questions/39227530/swift-reload-view-for-displaying-new-data-in-chart
            
            if (graphViews[index].data!.dataSets[0].entryCount > 100){ // replace 100 with custom size
                graphViews[index].data!.dataSets[0].removeFirst(); // returns the removed var but dont need it so ignore this error ->
            }
            
            graphViews[index].data!.notifyDataChanged();
            
            DispatchQueue.main.sync {
                graphViews[index].notifyDataSetChanged();
            }
            
        }
        return result;
    }
    
    public func getGraphLine(with index: Int, lineIndex: Int) -> LineChartDataSet?{
        return graphViews[index].data?.dataSets[lineIndex] as? LineChartDataSet;
    }
    
}
