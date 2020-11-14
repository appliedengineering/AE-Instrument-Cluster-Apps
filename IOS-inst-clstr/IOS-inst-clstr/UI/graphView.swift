//
//  graphView.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/12/20.
//

import Foundation
import UIKit
import AudioToolbox

class graphViewClass: UIViewController, UIScrollViewDelegate{
    var graphIndex = -1;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        AppUtility.lockOrientation(.all);
            
        renderPage(isLandscape: false);
    }
    
    @objc func dismissPage(sender: UIButton){
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait);
        dismiss(animated: true);
    }
    
    func renderPage(isLandscape: Bool){
        
        for subview in self.view.subviews{
            subview.removeFromSuperview();
        }
        let containerSize = CGSize(width: (isLandscape ? AppUtility.originalHeight : AppUtility.originalWidth), height: (isLandscape ? AppUtility.originalWidth : AppUtility.originalHeight));
        
        let topViewFrame = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height / (isLandscape ? 10 : 15));
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
        
        self.view.addSubview(topView);
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        renderPage(isLandscape: UIDevice.current.orientation.isLandscape);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        //print("removed view")
        AppUtility.lockOrientation(.portrait);
    }
    
}
