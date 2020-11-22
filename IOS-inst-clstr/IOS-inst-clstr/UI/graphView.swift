//
//  graphView.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/12/20.
//

import Foundation
import UIKit
import AudioToolbox
import Charts

class graphViewClass: UIViewController, UIScrollViewDelegate, ChartViewDelegate{
    var graphIndex = -1;
    
    var currentGraph : LineChartView = LineChartView();
    var noDataLabel : UILabel = UILabel();
    var selectedPointLabel : UILabel = UILabel();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        AppUtility.lockOrientation(.all);
            
        renderPage(isLandscape: false);
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateGraph), name:NSNotification.Name(rawValue: "updateGraph"), object: nil);
    }
    
    @objc func dismissPage(sender: UIButton){
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait);
        dismiss(animated: true);
    }
    
    @objc func updateGraph(){
        //currentGraph.data!.dataSets[0].addEntry(graphs.graphViews[graphIndex].data!.dataSets[0].)
        DispatchQueue.main.sync {
            currentGraph.data = graphs.graphViews[graphIndex].data;
            noDataLabel.isHidden = currentGraph.data?.dataSets[0].entryCount != 0;
        }
    }
    
    func renderPage(isLandscape: Bool){
        
        for subview in self.view.subviews{
            subview.removeFromSuperview();
        }
        let containerSize = CGSize(width: (isLandscape ? AppUtility.originalHeight : AppUtility.originalWidth), height: (isLandscape ? AppUtility.originalWidth : AppUtility.originalHeight));
        
        var nextY = CGFloat((!isLandscape ? AppUtility.topSafeAreaInsetHeight : 0));
        
        let topViewFrame = CGRect(x: 0, y: nextY, width: containerSize.width, height: containerSize.height / (isLandscape ? 10 : 15));
        let topView = UIButton(frame: topViewFrame);
        topView.backgroundColor = graphs.graphColorArray[graphIndex];
        
        topView.addTarget(self, action: #selector(dismissPage), for: .touchUpInside);
        
        let topLabelText = graphs.graphNameArray[graphIndex];
        let topLabelFont = UIFont(name: "SFProDisplay-Semibold", size: 18)!;
        let topLabelWidth = topLabelText.getWidth(withConstrainedHeight: topViewFrame.height, font: topLabelFont);
        let topLabelFrame = CGRect(x: (topViewFrame.width / 2) - (topLabelWidth/2), y: 0, width: topLabelWidth, height: topViewFrame.height);
        let topLabel = UILabel(frame: topLabelFrame);
        topLabel.text = topLabelText;
        topLabel.font = topLabelFont;
        topLabel.textColor = topView.backgroundColor?.isLight() ?? true ? UIColor.black : UIColor.white;
        
        topView.addSubview(topLabel);
        
        nextY += topViewFrame.height;
        
        if (!isLandscape){
            topView.roundCorners(corners: [.topLeft, .topRight], radius: 12);
        }
        
        //let selectedPointHorizontalPadding = CGFloat(10);
        //let selectedPointVerticalPadding = CGFloat(10);
        
        self.view.addSubview(topView);
        
        let selectedPointHeight = CGFloat(6*UIScreen.main.scale);
        let selectedPointHorizontalPadding = CGFloat(10);
        let selectedPointFrame = CGRect(x: selectedPointHorizontalPadding, y: nextY, width: containerSize.width - 2*selectedPointHorizontalPadding, height: selectedPointHeight); // scale is 3
        let selectedPoint = UILabel(frame: selectedPointFrame);
        selectedPoint.text = "Selected Point: (x: nil, y: nil)";
        selectedPoint.font = UIFont(name: "SFProDisplay-Semibold", size: 4*UIScreen.main.scale);
        //selectedPoint.backgroundColor = BackgroundGray;
        selectedPoint.textAlignment = .left;
        selectedPoint.textColor = InverseBackgroundColor;
        selectedPoint.isHidden = true;
        
        selectedPointLabel = selectedPoint;
        
        self.view.addSubview(selectedPoint);
        
        nextY += selectedPointFrame.height;
        
        let graphViewFrame = CGRect(x: 0, y: nextY, width: containerSize.width, height: containerSize.height - nextY - 10);
        let graphView = LineChartView(frame: graphViewFrame);
        
        graphView.backgroundColor = UIColor.clear;
        graphView.legend.enabled = false;
        graphView.rightAxis.enabled = false;
        graphView.leftAxis.drawAxisLineEnabled = false;
        graphView.leftAxis.drawGridLinesEnabled = false;
        graphView.xAxis.drawAxisLineEnabled = false;
        graphView.xAxis.drawGridLinesEnabled = false;
        graphView.drawGridBackgroundEnabled = false;
        /*let line = LineChartDataSet(entries: [ChartDataEntry]());
        
        line.fill = Fill.fillWithLinearGradient(CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [graphs.graphColorArray[graphIndex].cgColor, UIColor.clear.cgColor] as CFArray, locations: [1.0, 0.0])!, angle: 90.0);
        line.drawFilledEnabled = true;
        line.drawCirclesEnabled = false;
        line.drawValuesEnabled = false;
        line.colors = [graphs.graphColorArray[graphIndex]];
        line.mode = .cubicBezier;
        
        //graphs.graphViews[graphIndex].data!.dataSets[0];
        
        let lineData = LineChartData();
        
        lineData.addDataSet(line);
        
        print("data size - \(line.entries.count) compared to \(graphs.graphViews[graphIndex].data!.dataSets[0].entryCount)")*/
        graphView.data = graphs.graphViews[graphIndex].lineData;
        graphView.delegate = self;
        
        let noDataLabelWidth = CGFloat(100);
        let noDataLabelHeight = CGFloat(50);
        let noDataLabelFrame = CGRect(x: (graphViewFrame.width/2) - (noDataLabelWidth/2), y: (graphViewFrame.height/2)-(noDataLabelHeight/2), width: noDataLabelWidth, height: noDataLabelHeight);
        noDataLabel = UILabel(frame: noDataLabelFrame);
        noDataLabel.text = "No Data.";
        noDataLabel.textAlignment = .center;
        noDataLabel.textColor = InverseBackgroundColor;
        noDataLabel.font = UIFont(name: "SFProText-Bold", size: 5*UIScreen.main.scale);
        noDataLabel.isHidden = graphView.data?.dataSets[0].entryCount != 0;

        graphView.addSubview(noDataLabel);
        
        currentGraph = graphView;
        
        self.view.addSubview(graphView);
        
    }
    
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        selectedPointLabel.isHidden = false;
        selectedPointLabel.text = "Selected Point: (x: \(Float64(round(1000*entry.x)/1000)), y: \(entry.y))";
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        renderPage(isLandscape: UIDevice.current.orientation.isLandscape);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        //print("removed view")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateGraph"), object: nil);
        AppUtility.lockOrientation(.portrait);
    }
    
}
