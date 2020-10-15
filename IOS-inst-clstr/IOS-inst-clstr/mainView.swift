//
//  ViewController.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/12/20.
//

import UIKit

class mainViewClass: UIViewController {

    //@IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!

    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view.
        var nextY = CGFloat(UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0);
        
        let mainInstrumentViewHeight = CGFloat(UIScreen.main.bounds.width * 1.0666666666666667);
        let mainInstrumentViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: mainInstrumentViewHeight);
        let mainInstrumentView = UIView(frame: mainInstrumentViewFrame);
        mainInstrumentView.backgroundColor = UIColor.systemPink;
        
        nextY += mainInstrumentViewFrame.size.height;
        mainScrollView.addSubview(mainInstrumentView);
        
        // there are 6 different data streams that need to be displayed
        // one will be displayed on the main thingy at the top
        let dataStreamColors = [UIColor.green, UIColor.blue, UIColor.purple, UIColor.red, UIColor.yellow];
        let dataStreamViewHeight = CGFloat(UIScreen.main.bounds.width * 0.5333);
        for i in 0...4{
            let dataStreamViewFrame = CGRect(x: 0, y: nextY, width: UIScreen.main.bounds.width, height: dataStreamViewHeight);
            let dataStreamView = UIView(frame: dataStreamViewFrame);
            dataStreamView.backgroundColor = dataStreamColors[i];
            //print("ratio - \(dataStreamViewHeight / UIScreen.main.bounds.width)")
            nextY += dataStreamViewHeight;
            mainScrollView.addSubview(dataStreamView);
        }
        
        mainScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: nextY);
    }
}

