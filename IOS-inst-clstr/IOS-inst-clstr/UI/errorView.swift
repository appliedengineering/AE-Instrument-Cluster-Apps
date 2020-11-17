//
//  errorView.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/15/20.
//

import Foundation
import UIKit

struct errorTimestampStruct{
    var date : Date;
    //var calendar : Calendar;
    var hour : Int;
    var min : Int;
    var sec : Int;
    var isPM : Bool;
}

struct errorData {
    var description: String;
    var timeStamp: errorTimestampStruct;
    var isImportant = false;
}

class errorClass: UIViewController, UIScrollViewDelegate{
    
    static var errorBuffer = [errorData]();
    
    private var nextY = CGFloat(0);
    private var scrollView = UIScrollView();
    private let errorScrollViewPadding = CGFloat(0);
    
    @objc func dismissView(){
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
        dismiss(animated: true);
    }
    
    private func numOfDigitsOfInt(n: Int)->Int{
        var c = 0, t = n;
        while (t != 0){
            c+=1;
            t/=10;
        }
        return n == 0 ? 1 : c;
    }
    
    private func enforceDoubleCharFromInt(n: Int)->String{
        return (numOfDigitsOfInt(n: n) == 1 ? "0" : "") + "\(n)";
    }
    
    private func getTimestampStringFromData(error: errorData) -> String{
        //return "11:59:59 PM";
        let strct = error.timeStamp;
        return "\(enforceDoubleCharFromInt(n: strct.hour)):\(enforceDoubleCharFromInt(n: strct.min)):\(enforceDoubleCharFromInt(n: strct.sec)) \( strct.isPM ? "PM" : "AM")";
    }
    
    func createViewFromError(error: errorData) -> UIView{
        let errorViewWidth = self.view.frame.width - 2*errorScrollViewPadding;
        let errorViewBackgroundColor = error.isImportant ? UIColor.red : BackgroundColor;
        //let errorViewBackgroundColor = UIColor.white;
        
        let errorLabelText = error.description;
        let errorLabelWidth = 2 * errorViewWidth / 3;
        let errorLabelFont = UIFont(name: "SFProDisplay-Semibold", size: 15)!;
        let errorLabelHeight = errorLabelText.getHeight(withConstrainedWidth: errorLabelWidth, font: errorLabelFont);
        let errorLabelFrame = CGRect(x: 0, y: 0, width: errorLabelWidth, height: errorLabelHeight);
        let errorLabel = UILabel(frame: errorLabelFrame);
        errorLabel.text = errorLabelText;
        errorLabel.font = errorLabelFont;
        errorLabel.textAlignment = .left;
        errorLabel.textColor = errorViewBackgroundColor.isLight() ?? true ? UIColor.black : UIColor.white;
        errorLabel.numberOfLines = 0;
        //errorLabel.textColor = UIColor.black;
        
        let errorTimestampLabelText = getTimestampStringFromData(error: error);
        let errorTimestampWidth = errorViewWidth/3;
        let errorTimestampFont = UIFont(name: "SFProDisplay-Semibold", size: 18)!;
        let errorTimestampHeight = errorTimestampLabelText.getHeight(withConstrainedWidth: errorTimestampWidth, font: errorTimestampFont);
        let errorTimestampFrame = CGRect(x: errorLabelWidth, y: 0, width: errorTimestampWidth, height: errorTimestampHeight);
        let errorTimestamp = UILabel(frame: errorTimestampFrame);
        errorTimestamp.text = errorTimestampLabelText;
        errorTimestamp.font = errorTimestampFont;
        errorTimestamp.textAlignment = .center;
        errorTimestamp.textColor = errorViewBackgroundColor.isLight() ?? true ? UIColor.black : UIColor.white;
        errorTimestamp.numberOfLines = 0;
        //errorTimestamp.textColor = UIColor.black;
        //errorTimestamp.backgroundColor = UIColor.blue;
        
        //print("max height = \(max(errorLabel.frame.height, errorTimestamp.frame.height))")
        let errorViewFrame = CGRect(x: 0, y: nextY, width: errorViewWidth, height: max(errorLabel.frame.height, errorTimestamp.frame.height));
        let errorView = UIView(frame: errorViewFrame);
        errorView.backgroundColor = errorViewBackgroundColor;
        errorView.addSubview(errorLabel);
        errorView.addSubview(errorTimestamp);
        
        return errorView;
    }
    
    @objc func clearLogBuffer(){
        errorClass.errorBuffer = [errorData]();
        for subview in scrollView.subviews{
            subview.removeFromSuperview();
        }
        nextY = CGFloat(0);
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //print("load - \(self.view.frame)")
        let topViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/15);
        let topView = UIButton(frame: topViewFrame);
        topView.backgroundColor = BackgroundGray;
        
        let topLabelText = "Error Log";
        let topLabelFont = UIFont(name: "SFProDisplay-Semibold", size: 18)!;
        let topLabelWidth = topLabelText.getWidth(withConstrainedHeight: topViewFrame.height, font: topLabelFont);
        let topLabelFrame = CGRect(x: (topViewFrame.width / 2) - (topLabelWidth/2), y: 0, width: topLabelWidth, height: topViewFrame.height);
        let topLabel = UILabel(frame: topLabelFrame);
        topLabel.text = topLabelText;
        topLabel.font = topLabelFont;
        topLabel.textColor = topView.backgroundColor?.isLight() ?? true ? UIColor.black : UIColor.white;
        
        topView.addSubview(topLabel);
        
        let clearBufferButtonVerticalPadding = CGFloat(topViewFrame.height/10);
        let clearBufferButtonHorizontalPadding = CGFloat(topViewFrame.width / 15);
        let clearBufferButtonWidth = CGFloat(topViewFrame.width/5);
        let clearBufferButtonFrame = CGRect(x: topViewFrame.width - clearBufferButtonWidth - clearBufferButtonHorizontalPadding, y: clearBufferButtonVerticalPadding, width: clearBufferButtonWidth, height: topViewFrame.height - 2*clearBufferButtonVerticalPadding);
        let clearBufferButton = UIButton(frame: clearBufferButtonFrame);
        clearBufferButton.backgroundColor = BackgroundColor;
        clearBufferButton.setTitle("Clear Logs", for: .normal);
        clearBufferButton.setTitleColor(InverseBackgroundColor, for: .normal);
        clearBufferButton.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 12);
        clearBufferButton.titleLabel?.textAlignment = .center;
        clearBufferButton.layer.cornerRadius = 5;
        
        clearBufferButton.addTarget(self, action: #selector(clearLogBuffer), for: .touchUpInside);
        
        topView.addSubview(clearBufferButton);
        
        topView.addTarget(self, action: #selector(dismissView), for: .touchUpInside);
        
        self.view.addSubview(topView);
        
        let mainScrollViewFrame = CGRect(x: 0, y: topViewFrame.height, width: self.view.frame.width, height: self.view.frame.height - topViewFrame.height);
        let mainScrollView = UIScrollView(frame: mainScrollViewFrame);
        mainScrollView.backgroundColor = BackgroundColor;
        
        for error in errorClass.errorBuffer{
            let currentView = createViewFromError(error: error);
            currentView.tag = 1;
            mainScrollView.addSubview(currentView);
            nextY += currentView.frame.height;
        }
        
        scrollView = mainScrollView;
        mainScrollView.contentSize = CGSize(width: self.view.frame.width, height: nextY + 30);
        
        self.view.addSubview(mainScrollView);
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addLastErrorToView), name:NSNotification.Name(rawValue: "addError"), object: nil);
        
    }
    
    @objc func addLastErrorToView(){
        DispatchQueue.main.sync {
            //print("called last error - \(errorClass.errorBuffer[errorClass.errorBuffer.count - 1].description)")
            
            let currentView = createViewFromError(error: errorClass.errorBuffer[errorClass.errorBuffer.count - 1]);
            scrollView.addSubview(currentView);
            nextY += currentView.frame.height;
            
            scrollView.contentSize = CGSize(width: self.view.frame.width, height: nextY + 30);
            
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "addError"), object: nil);
    }
}
