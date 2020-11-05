//
//  settings.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/4/20.
//

import Foundation
import UIKit
import AudioToolbox

class settingsClass : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @objc func dismissView(){
        dismiss(animated: true);
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        mainScrollView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1).isActive = true;
        
        let topBarViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50);
        let topBarView = UIButton(frame: topBarViewFrame);
        
        topBarView.backgroundColor = UIColor.white;
        
        topBarView.addTarget(self, action: #selector(dismissView), for: .touchUpInside);
        
        let verticalPadding = CGFloat(topBarViewFrame.height/4);
        
        let backButtonSide = CGFloat(topBarViewFrame.height - 2*verticalPadding);
        let backButtonFrame = CGRect(x: verticalPadding + 5, y: verticalPadding, width: 1.2*backButtonSide, height: backButtonSide);
        
        let backButton = UIImageView(frame: backButtonFrame);
        backButton.image = UIImage(systemName: "arrow.left");
        backButton.tintColor = UIColor.black;
        
        topBarView.addSubview(backButton);
    
        let titleLabelFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: topBarViewFrame.height);
        let titleLabel = UILabel(frame: titleLabelFrame);
        titleLabel.text = "Settings";
        titleLabel.font = UIFont(name: "Helvetica-Bold", size: 22);
        titleLabel.textAlignment = .center;
        titleLabel.textColor = UIColor.black;
        //titleLabel.backgroundColor = UIColor.blue;
        
        topBarView.addSubview(titleLabel);
        
        mainView.addSubview(topBarView);
        
        
        
    }
}
