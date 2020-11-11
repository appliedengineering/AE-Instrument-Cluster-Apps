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
    
    func updateGraph(with index: Int, point: ChartDataEntry) -> Bool{
        //print(type(of: graphViews[index].data!.dataSets[0]))
        //print("add point - \(point)")
        let result = graphViews[index].data!.dataSets[0].addEntry(point);
        if (result){
            
            // https://stackoverflow.com/questions/39227530/swift-reload-view-for-displaying-new-data-in-chart
            
            graphViews[index].data!.notifyDataChanged();
            graphViews[index].notifyDataSetChanged();
        }
        return result;
    }
    
    func getGraphLine(with index: Int, lineIndex: Int) -> LineChartDataSet?{
        return graphViews[index].data?.dataSets[lineIndex] as? LineChartDataSet;
    }
    
}
