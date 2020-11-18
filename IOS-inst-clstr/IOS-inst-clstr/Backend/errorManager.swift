//
//  errorManager.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/15/20.
//

import Foundation
import UIKit
import AudioToolbox

class errorManager{
    
    static let obj = errorManager();
    
    private init(){}
    
    public func addErrorToBuffer(error: errorData){
        errorClass.errorBuffer.append(error);
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addError"), object: nil);
    }
    
    public func addImportantErrorToBuffer(error: errorData) -> UIAlertController{
        addErrorToBuffer(error: error);
        
        // you should look for "TODO:importantError" in the code where it calls this function
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
        // create uialertcontroller so that it can be presented
        let errorPopup = UIAlertController(title: "Critical Error", message: error.description, preferredStyle: UIAlertController.Style.actionSheet);
        errorPopup.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: {(action: UIAlertAction!) in
            // add custom actions here
        }));
        
        return errorPopup;
    }
    
    public func createTimestampStruct() -> errorTimestampStruct{
        let date = Date();
        let calendar = Calendar.current;
        var hour = calendar.component(.hour, from: date);
        let minutes = calendar.component(.minute, from: date);
        let seconds = calendar.component(.second, from: date);
        var isPM = false;
        if (hour >= 12){
            isPM = true;
            hour %= 12;
            if (hour == 0){
                hour = 12;
            }
        }
        return errorTimestampStruct(date: date, hour: hour, min: minutes, sec: seconds, isPM: isPM);
    }
    
}
