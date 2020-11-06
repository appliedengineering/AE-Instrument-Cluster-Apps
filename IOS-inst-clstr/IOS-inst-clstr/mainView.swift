//
//  ViewController.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/12/20.
//

import UIKit
import MessagePacker
import AudioToolbox

let protocolString = "udp";
var connectionIPAddress = "";
var connectionPort = "";
var connectionAddress = "";
var connectionGroup = "";
var recieveTimeout = -1; // in ms

var reconnectTimeout = -1; // in sec

let communication = communicationClass();

class mainViewClass: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {

    //@IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var hamBurgMenuView: UIView!
    @IBOutlet weak var hamBurgMenuScrollView: UIScrollView!
    
    @IBOutlet weak var mainViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hamBurgMenuViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var hamBurgMenuViewWidthConstraint: NSLayoutConstraint!
    
    let hamBurgMenuViewWidth = CGFloat(270);
    
    var topSafeAreaInsetHeight = CGFloat(0);
    let scrollViewFadeButtonThresholdHeight = CGFloat(250);
    let settingsButton = UIButton();

    
    // textfields needed to submit in settings
    let ipAddressInput = UITextField();
    // end textfields
    
    func loadPreferences(){
        connectionIPAddress = "224.0.0.1"; // defaults
        connectionPort = "28650"; // defaults
        recieveTimeout = 1000; // defaults
        connectionGroup = "telemetry"; // defaults
        reconnectTimeout = 3; // defaults
        // load user pref
        
        
        connectionAddress = protocolString + "://" + connectionIPAddress + ":" + connectionPort;
    }
    
    
    // HamBurg menu funcs and vars
    
    var isHamBurgMenuOpen = false;
    
    @objc func toggleHamBurgMenu(){
        
        if (isHamBurgMenuOpen){
            hamBurgMenuViewLeadingConstraint.constant = -hamBurgMenuViewWidth;
            self.view.endEditing(true);
            isHamBurgMenuOpen = false;
        }
        else{
            hamBurgMenuViewLeadingConstraint.constant = 0;
            isHamBurgMenuOpen = true;
        }
    
    }
    
    // end HamBurg menu funcs and vars
    
    // SFProDisplay-Regular, SFProDisplay-Semibold, SFProDisplay-Black, SFProText-Bold
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view
        
        
        loadPreferences();
        
        //printAllFonts();
        topSafeAreaInsetHeight = UIApplication.shared.windows[0].safeAreaInsets.top;
        
        // set up outerview stuff
        
        mainViewWidthConstraint.constant = UIScreen.main.bounds.width;
        
        mainView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
        mainView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
        hamBurgMenuView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true;
        hamBurgMenuView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true;
    
        hamBurgMenuViewWidthConstraint.constant = hamBurgMenuViewWidth;
        
        //
        
        // ham burg menu rendering stuff
        // we won't have to rerender this menu because it only takes in stuff for addresses and crap
        
        
        
        var nextY = topSafeAreaInsetHeight;
        
        let horizontalPadding = CGFloat(20);
        let subVerticalPadding = CGFloat(10);
        let verticalPadding = CGFloat(10);
        
        let hamBurgMenuSubViewWidth = hamBurgMenuViewWidth - 2*horizontalPadding;
        let hamBurgMenuInputHeight = CGFloat(35);
        let hamBurgMenuTextHeight = CGFloat(50);
        
        
        let settingsHeaderFrame = CGRect(x: 0, y: nextY, width: hamBurgMenuViewWidth, height: hamBurgMenuTextHeight);
        let settingsHeader = UILabel(frame: settingsHeaderFrame);
        settingsHeader.text = "Settings";
        settingsHeader.textAlignment = .center;
        settingsHeader.font = UIFont(name: "SFProDisplay-Black", size: 25);
        settingsHeader.textColor = InverseBackgroundColor;
        
        hamBurgMenuScrollView.addSubview(settingsHeader);
        nextY += settingsHeaderFrame.height + verticalPadding;
        
        let ipAddressLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let ipAddressLabel = UILabel(frame: ipAddressLabelFrame);
        ipAddressLabel.text = "Connection IP Address";
        ipAddressLabel.textColor = InverseBackgroundColor;
        ipAddressLabel.textAlignment = .left;
        ipAddressLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        //ipAddressLabel.backgroundColor = UIColor.blue;
        
        hamBurgMenuScrollView.addSubview(ipAddressLabel);
        nextY += ipAddressLabelFrame.height;
        
        let ipAddressInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        ipAddressInput.frame = ipAddressInputFrame; // already declared above
        ipAddressInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        ipAddressInput.text = connectionIPAddress;
        ipAddressInput.allowsEditingTextAttributes = false;
        ipAddressInput.autocorrectionType = .no;
        ipAddressInput.spellCheckingType = .no;
        ipAddressInput.keyboardType = .numbersAndPunctuation; // experiment with this
        ipAddressInput.setUnderLine();
        ipAddressInput.delegate = self;
        
        hamBurgMenuScrollView.addSubview(ipAddressInput);
        nextY += ipAddressInputFrame.height + verticalPadding;
        
        
        hamBurgMenuScrollView.contentSize = CGSize(width: hamBurgMenuViewWidth, height: nextY);
        hamBurgMenuScrollView.delegate = self;
        
        
        // end ham burg menu rendering
        
        // set up view buttons
        let settingsButtonPadding = CGFloat(12);
        let settingsButtonWidth = CGFloat(20*UIScreen.main.scale);
        let settingsButtonFrame = CGRect(x: settingsButtonPadding, y: settingsButtonPadding + topSafeAreaInsetHeight, width: settingsButtonWidth, height: settingsButtonWidth);
        settingsButton.frame = settingsButtonFrame;
        settingsButton.backgroundColor = UIColor.gray;
        
        settingsButton.clipsToBounds = true;
        settingsButton.layer.cornerRadius = settingsButtonWidth/2;
        
        settingsButton.addTarget(self, action: #selector(toggleHamBurgMenu), for: .touchUpInside);
        
        mainView.addSubview(settingsButton);
   
        mainScrollView.tag = -1;
        //mainScrollView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1).isActive = true;
        mainScrollView.delegate = self;
        mainScrollView.showsVerticalScrollIndicator = false;
        mainScrollView.showsHorizontalScrollIndicator = false;
        
        renderViews();
        
        
        communicationThread();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
    
    func communicationThread(){
        // use multithreading to get the actual data from communication.swift and msgpack.swift then use main thread to set ui elements
        DispatchQueue.global(qos: .background).async{
            while true{ // keeps on reconnecting
                if (communication.connect(connectionstr: connectionAddress, connectionGroup: connectionGroup, recvTimeout: recieveTimeout)){
                    
                    while communication.dish != nil{
                       // print("iteration");
                        
                        do{
                            
                            let data = try MessagePackDecoder().decode(APiDataPack.self, from: try communication.dish?.recv(options: .none) ?? Data());
                            print("recieved data - \(data)");
                        }
                        catch {
                            //print("recieved catch")
                            if ("\(error)" != "Resource temporarily unavailable"){ // super hacky but it works lmao
                                print("Communication recieve error - \(error)");
                            }
                        }
                    }
                    
                }
                else{
                    // also access lastCommunicationError for string of error
                    print("Communication setup error - see above console output for reason.");
                }
                
                sleep(UInt32(reconnectTimeout));
               // print("sleep")
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
    
        let headerViewHeight = CGFloat(50);
        let headerViewFrame = CGRect(x: 0, y: nextY, width: UIScreen.main.bounds.width, height: headerViewHeight);
        let headerView = UIView(frame: headerViewFrame);
        
        headerView.backgroundColor = UIColor.systemBackground;
        
        let appIconViewVerticalPadding = CGFloat(5);
        let appIconViewSide = CGFloat(headerViewHeight - 2*appIconViewVerticalPadding);
        let appIconViewFrame = CGRect(x: (headerViewFrame.size.width / 2) - (appIconViewSide / 2), y: appIconViewVerticalPadding, width: appIconViewSide, height: appIconViewSide);
        let appIconView = UIImageView(frame: appIconViewFrame);
        appIconView.image = UIImage(named: "AELogo");
        appIconView.contentMode = .scaleAspectFill;
        
        headerView.addSubview(appIconView);
        
        mainScrollView.addSubview(headerView);
        
        nextY += headerViewHeight;
        
        let mainInstrumentViewHeight = CGFloat(screenWidth * 1.0666666666666667);
        let mainInstrumentViewFrame = CGRect(x: 0, y: nextY, width: screenWidth, height: mainInstrumentViewHeight);
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

