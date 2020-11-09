//
//  graphManager.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/8/20.
//

import Foundation
import UIKit
import Charts

class graphManager{
    let numOfGraphs = 10;
    let graphNameArray = ["RPM", "Torque", "Throttle (%)", "Duty (%)", "PWM Frequency", "Temperature (C)", "Source Voltage", "PWM Current", "Power Change (Δ)", "Voltage Change (Δ)"];
    var graphViews = [LineChartView](); // This should be populated with chart views after first render

}
