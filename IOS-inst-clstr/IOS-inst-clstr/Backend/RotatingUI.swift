//
//  RotatingUI.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 11/13/20.
//

import Foundation
import UIKit

class RotatingUIView: UIView{
    override func layoutSubviews() {
        super.layoutSubviews();
        self.setNeedsDisplay();
    }
}

class RotatingUILabel:UILabel{
    override func layoutSubviews() {
        super.layoutSubviews();
        self.setNeedsDisplay();
    }
}
