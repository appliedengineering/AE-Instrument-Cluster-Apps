//
//  ViewController.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/12/20.
//

import UIKit
import MessagePacker

let protocolString = "udp";
var connectionIPAddress = "";
var connectionPort = "";
var connectionAddress = "";
var recieveTimeout = 0;

let communication = communicationClass();

class mainViewClass: UIViewController, UIScrollViewDelegate {

    //@IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet var mainView: UIView!
    
    var topSafeAreaInsetHeight = CGFloat(0);
    let scrollViewFadeButtonThresholdHeight = CGFloat(250);
    let settingsButton = UIButton();
    
    func loadPreferences(){
        connectionIPAddress = "224.0.0.1"; // defaults
        connectionPort = "28650"; // defaults
        recieveTimeout = 1000; // defaults
        
        // load user pref
        
        
        connectionAddress = protocolString + "://" + connectionIPAddress + ":" + connectionPort;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view
        
        
        loadPreferences();
        
        
        topSafeAreaInsetHeight = UIApplication.shared.windows[0].safeAreaInsets.top;
        // set up view buttons
        let settingsButtonPadding = CGFloat(12);
        let settingsButtonWidth = CGFloat(20*UIScreen.main.scale);
        let settingsButtonFrame = CGRect(x: settingsButtonPadding, y: settingsButtonPadding + topSafeAreaInsetHeight, width: settingsButtonWidth, height: settingsButtonWidth);
        settingsButton.frame = settingsButtonFrame;
        settingsButton.backgroundColor = UIColor.gray;
        
        mainView.addSubview(settingsButton);
   
        mainScrollView.tag = -1;
        //mainScrollView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1).isActive = true;
        mainScrollView.delegate = self;
        renderViews();
    
        
        //let comms = communicationClass(connectionstr: connectionAddress, communicationProtocol: protocolString);
        //let msgpack = msgpackClass();
        
        // use multithreading to get the actual data from communication.swift and msgpack.swift then use main thread to set ui elements
        DispatchQueue.global(qos: .background).async{
            
            if (!communication.setup(connectionstr: connectionAddress, recvTimeout: recieveTimeout)){
                // errored out
                print("Communicatin setup error - see above console output for reason.");
            }
            else{
                
                while true{
                    do{
                        
                        //print("iteration")
                        
                        let data = try MessagePackDecoder().decode(String.self, from: try communication.dish?.recv(options: .none) ?? Data());
                        print("recieved data - \(data) - \(type(of: data))");
                        
                        
                    }
                    catch {
                        if ("\(error)" != "Resource temporarily unavailable"){ // super hacky but it works lmao
                            print("Communication recieve error - \(error)");
                        }
                        else{
                            print("No data packets recieved");
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    
    func renderViews(){
        
        for view in mainScrollView.subviews{
            if (view.tag == 1){
                view.removeFromSuperview();
            }
        }
        let screenWidth = UIScreen.main.bounds.width;
        
        var nextY = CGFloat(0);
    
        
        let mainInstrumentViewHeight = CGFloat(screenWidth * 1.0666666666666667);
        let mainInstrumentViewFrame = CGRect(x: 0, y: 0, width: screenWidth, height: mainInstrumentViewHeight);
        let mainInstrumentView = UIView(frame: mainInstrumentViewFrame);
        mainInstrumentView.backgroundColor = UIColor.systemPink;
        mainInstrumentView.tag = 1;
        
        nextY += mainInstrumentViewFrame.size.height;
        mainScrollView.addSubview(mainInstrumentView);
        
        // there are 6 different data streams that need to be displayed
        // one will be displayed on the main thingy at the top
        let dataStreamColors = [UIColor.green, UIColor.blue, UIColor.purple, UIColor.red, UIColor.yellow];
        let dataStreamViewHeight = CGFloat(screenWidth * 0.5333);
        for i in 0...4{
            let dataStreamViewFrame = CGRect(x: 0, y: nextY, width: screenWidth, height: dataStreamViewHeight);
            let dataStreamView = UIView(frame: dataStreamViewFrame);
            dataStreamView.backgroundColor = dataStreamColors[i];
            //print("ratio - \(dataStreamViewHeight / UIScreen.main.bounds.width)")
            dataStreamView.tag = 1;
            nextY += dataStreamViewHeight;
            mainScrollView.addSubview(dataStreamView);
        }
        
        mainScrollView.contentSize = CGSize(width: screenWidth, height: nextY);
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.tag == -1){
            let scrollContentYPercent = min(1, max(1 - ((scrollView.contentOffset.y + topSafeAreaInsetHeight) / scrollViewFadeButtonThresholdHeight), 0)); // some maths
            //print("scroll content offset = \(scrollView.contentOffset.y) : \(scrollContentYPercent)")
            settingsButton.alpha = scrollContentYPercent;
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // rerender homescreen
        print("changed orientation");
        renderViews();
    }
    
    
}

