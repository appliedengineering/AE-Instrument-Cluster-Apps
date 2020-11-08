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
    @IBOutlet weak var hamBurgMenuScrollViewHeightConstraint: NSLayoutConstraint!
    
    let hamBurgMenuViewWidth = CGFloat(270);
    
    
    var topSafeAreaInsetHeight = CGFloat(0);
    let scrollViewFadeButtonThresholdHeight = CGFloat(200);
    let settingsButton = UIButton();

    
    // textfields needed to submit in settings
    let ipAddressInput = UITextField();
    let connectionPortInput = UITextField();
    let connectionGroupInput = UITextField();
    let recieveTimeoutInput = UITextField(); // in ms
    let reconnectTimeoutInput = UITextField(); // in sec
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
    
    var enableHamBurgMenu = false;
    
    @objc func toggleHamBurgMenu(){
        //rint("toggled - \(enableHamBurgMenu)")
        if (enableHamBurgMenu){
            closeHamBurgMenu();
        }
        else{
            openHamBurgMenu();
        }
    
    }
    
    func openHamBurgMenu(){
        enableHamBurgMenu = true;
        //self.hamBurgMenuViewLeadingConstraint.constant = 0;
        UIView.animate(withDuration: 0.2){
            self.hamBurgMenuViewLeadingConstraint.constant = 0;
            self.view.layoutIfNeeded();
        }
    }
    
    func closeHamBurgMenu(){
        enableHamBurgMenu = false;
        //self.hamBurgMenuViewLeadingConstraint.constant = -self.hamBurgMenuViewWidth;
        UIView.animate(withDuration: 0.2){
            self.hamBurgMenuViewLeadingConstraint.constant = -self.hamBurgMenuViewWidth; // const
            self.view.layoutIfNeeded();
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) { // main goal is to set the hamburgmenuconstraint
        let percentThreshold: CGFloat = 0.3;
        let sensitivity = CGFloat(5); // 0 to x, where 1 is normal multiplier
        let translation = sender.translation(in: view);
        let fingerMovement = translation.x / view.bounds.width;
        //print("moved - \(fingerMovement)");
        if (enableHamBurgMenu){ // exit menu
            let rightMovement = fmaxf(Float(-fingerMovement), 0.0);
            let rightMovementPercent = fminf(rightMovement, 1.0);
            let progress = CGFloat(rightMovementPercent);
            if (sender.state == .began || sender.state == .changed){
                //print("exit pan - \(progress)");
                if (progress == 1){
                    closeHamBurgMenu();
                }
                else{
                    UIView.animate(withDuration: 0.2){
                        self.hamBurgMenuViewLeadingConstraint.constant = -(self.hamBurgMenuViewWidth * min(progress * sensitivity, 1.0));
                        self.view.layoutIfNeeded();
                    }
                }
            }
            else if (sender.state == .ended){
                //print("stop exit pan - \(progress)");
                if (progress > percentThreshold){
                    closeHamBurgMenu();
                }
                else{
                    openHamBurgMenu();
                }
            }
        }
        else{ // open menu
            let leftMovement = fminf(Float(fingerMovement), 1.0);
            let leftMovementPercent = fmaxf(leftMovement, 0.0);
            let progress = CGFloat(leftMovementPercent);
            if (sender.state == .began || sender.state == .changed){
                //print("start pan - \(progress)");
                if (progress == 1){
                    openHamBurgMenu();
                }
                else{
                    UIView.animate(withDuration: 0.2){
                        self.hamBurgMenuViewLeadingConstraint.constant = -self.hamBurgMenuViewWidth + (self.hamBurgMenuViewWidth * min(progress * sensitivity, 1.0));
                        self.view.layoutIfNeeded();
                    }
                }
            }
            else if (sender.state == .ended){
                //print("stop start pan - \(progress)");
                if (progress > percentThreshold){
                    openHamBurgMenu();
                }
                else{
                    closeHamBurgMenu();
                }
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scrollView = otherGestureRecognizer.view as? UIScrollView {
            return scrollView.contentOffset.x == 0;
        }
        return false
    }
    
    @objc func applySettings(){
        
    }
    
    func renderHamBurgMenu(){
        // ham burg menu rendering stuff
        // we won't have to rerender this menu because it only takes in stuff for addresses and crap
        
        for subview in hamBurgMenuScrollView.subviews{
            if (subview.tag == 1){
                subview.removeFromSuperview();
            }
        }
        
        var nextY = topSafeAreaInsetHeight;
        
        let horizontalPadding = CGFloat(20);
        //let subVerticalPadding = CGFloat(10);
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
        settingsHeader.tag = 1;
        
        hamBurgMenuScrollView.addSubview(settingsHeader);
        nextY += settingsHeaderFrame.height + verticalPadding;
        
        /// ------- IP ADDRESS
        
        let ipAddressLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let ipAddressLabel = UILabel(frame: ipAddressLabelFrame);
        ipAddressLabel.text = "Connection IP Address";
        ipAddressLabel.textColor = InverseBackgroundColor;
        ipAddressLabel.textAlignment = .left;
        ipAddressLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        ipAddressLabel.tag = 1;
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
        ipAddressInput.keyboardType = .decimalPad; // experiment with this
        ipAddressInput.setUnderLine();
        ipAddressInput.delegate = self;
        ipAddressInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(ipAddressInput);
        nextY += ipAddressInputFrame.height + verticalPadding;
        
        /// ----- CONNECTION PORT
        
        let connectionPortLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let connectionPortLabel = UILabel(frame: connectionPortLabelFrame);
        connectionPortLabel.text = "Connection Port";
        connectionPortLabel.textColor = InverseBackgroundColor;
        connectionPortLabel.textAlignment = .left;
        connectionPortLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        connectionPortLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(connectionPortLabel);
        nextY += connectionPortLabelFrame.height;
        
        let connectionPortInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        connectionPortInput.frame = connectionPortInputFrame; // already declared above
        connectionPortInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        connectionPortInput.text = connectionPort;
        connectionPortInput.allowsEditingTextAttributes = false;
        connectionPortInput.autocorrectionType = .no;
        connectionPortInput.spellCheckingType = .no;
        connectionPortInput.keyboardType = .numberPad; // experiment with this
        connectionPortInput.setUnderLine();
        connectionPortInput.delegate = self;
        connectionPortInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(connectionPortInput);
        nextY += connectionPortInputFrame.height + verticalPadding;
        
        /// -------- CONNECTION GROUP
        
        let connectionGroupLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let connectionGroupLabel = UILabel(frame: connectionGroupLabelFrame);
        connectionGroupLabel.text = "Connection Group";
        connectionGroupLabel.textColor = InverseBackgroundColor;
        connectionGroupLabel.textAlignment = .left;
        connectionGroupLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        connectionGroupLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(connectionGroupLabel);
        nextY += connectionGroupLabelFrame.height;
        
        let connectionGroupInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        connectionGroupInput.frame = connectionGroupInputFrame; // already declared above
        connectionGroupInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        connectionGroupInput.text = connectionGroup;
        connectionGroupInput.allowsEditingTextAttributes = false;
        connectionGroupInput.autocorrectionType = .no;
        connectionGroupInput.spellCheckingType = .no;
        connectionGroupInput.keyboardType = .default; // experiment with this
        connectionGroupInput.setUnderLine();
        connectionGroupInput.delegate = self;
        connectionGroupInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(connectionGroupInput);
        nextY += connectionGroupInputFrame.height + verticalPadding;
        
        /// ----------- RECIEVE TIMEOUT
        
        let recieveTimeoutLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let recieveTimeoutLabel = UILabel(frame: recieveTimeoutLabelFrame);
        recieveTimeoutLabel.text = "Recieve Timeout (ms)";
        recieveTimeoutLabel.textColor = InverseBackgroundColor;
        recieveTimeoutLabel.textAlignment = .left;
        recieveTimeoutLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        recieveTimeoutLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(recieveTimeoutLabel);
        nextY += recieveTimeoutLabelFrame.height;
        
        let recieveTimeoutInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        recieveTimeoutInput.frame = recieveTimeoutInputFrame; // already declared above
        recieveTimeoutInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        recieveTimeoutInput.text = String(recieveTimeout);
        recieveTimeoutInput.allowsEditingTextAttributes = false;
        recieveTimeoutInput.autocorrectionType = .no;
        recieveTimeoutInput.spellCheckingType = .no;
        recieveTimeoutInput.keyboardType = .numberPad; // experiment with this
        recieveTimeoutInput.setUnderLine();
        recieveTimeoutInput.delegate = self;
        recieveTimeoutInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(recieveTimeoutInput);
        nextY += recieveTimeoutInputFrame.height + verticalPadding;
        
        /// ----------- RECONNECT TIMEOUT
        
        let reconnectTimeoutLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let reconnectTimeoutLabel = UILabel(frame: reconnectTimeoutLabelFrame);
        reconnectTimeoutLabel.text = "Reconnect Timeout (s)";
        reconnectTimeoutLabel.textColor = InverseBackgroundColor;
        reconnectTimeoutLabel.textAlignment = .left;
        reconnectTimeoutLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        reconnectTimeoutLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(reconnectTimeoutLabel);
        nextY += reconnectTimeoutLabelFrame.height;
        
        let reconnectTimeoutInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        reconnectTimeoutInput.frame = reconnectTimeoutInputFrame; // already declared above
        reconnectTimeoutInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        reconnectTimeoutInput.text = String(reconnectTimeout);
        reconnectTimeoutInput.allowsEditingTextAttributes = false;
        reconnectTimeoutInput.autocorrectionType = .no;
        reconnectTimeoutInput.spellCheckingType = .no;
        reconnectTimeoutInput.keyboardType = .numberPad; // experiment with this
        reconnectTimeoutInput.setUnderLine();
        reconnectTimeoutInput.delegate = self;
        reconnectTimeoutInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(reconnectTimeoutInput);
        nextY += reconnectTimeoutInputFrame.height + verticalPadding;
        
        //// --- FINAL ADDRESS
        
        let fullAddressLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let fullAddressLabel = UILabel(frame: fullAddressLabelFrame);
        fullAddressLabel.text = "Full Address";
        fullAddressLabel.textColor = InverseBackgroundColor;
        fullAddressLabel.textAlignment = .left;
        fullAddressLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        fullAddressLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(fullAddressLabel);
        nextY += fullAddressLabelFrame.height;
        
        let fullAddressFont = UIFont(name: "SFProDisplay-Semibold", size: 18);
        let fullAddressHeight = connectionAddress.getHeight(withConstrainedWidth: hamBurgMenuSubViewWidth, font: fullAddressFont!);
        let fullAddressFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: fullAddressHeight);
        let fullAddress = UITextView(frame: fullAddressFrame);
        fullAddress.text = connectionAddress;
        fullAddress.font = fullAddressFont;
        fullAddress.textColor = InverseBackgroundColor;
        fullAddress.setUnderLine();
        fullAddress.isEditable = false;
        fullAddress.isSelectable = false;
        fullAddress.isUserInteractionEnabled = false;
        fullAddress.isScrollEnabled = false;
        fullAddress.textContainerInset = UIEdgeInsets(top: -4, left: -4, bottom: 0, right: 0);
        fullAddress.tag = 1;
        
        hamBurgMenuScrollView.addSubview(fullAddress);
        nextY += fullAddressHeight + 2*verticalPadding;
        
        
        let applySettingsButtonFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: 40);
        let applySettingsButton = UIButton(frame: applySettingsButtonFrame);
        applySettingsButton.backgroundColor = BackgroundGray;
        applySettingsButton.setTitle("Apply Settings", for: .normal);
        applySettingsButton.setTitleColor(InverseBackgroundColor, for: .normal);
        applySettingsButton.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        applySettingsButton.titleLabel?.textAlignment = .center;
        applySettingsButton.layer.cornerRadius = 4;
        applySettingsButton.tag = 1;
        
        applySettingsButton.addTarget(self, action: #selector(applySettings), for: .touchUpInside);
        
        hamBurgMenuScrollView.addSubview(applySettingsButton);
        nextY += applySettingsButtonFrame.height + verticalPadding;
        
        // END
        
        hamBurgMenuScrollView.contentSize = CGSize(width: hamBurgMenuViewWidth, height: nextY);
        hamBurgMenuScrollView.delegate = self;
        
        // end ham burg menu rendering
    }
    
    // end HamBurg menu funcs and vars
    
    // SFProDisplay-Regular, SFProDisplay-Semibold, SFProDisplay-Black, SFProText-Bold
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view
        self.hideKeyboardWhenTappedAround();
        
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
        
        renderHamBurgMenu();
        
        // set up view buttons
        //let settingsButtonPadding = CGFloat(12);
        let settingsButtonHeight = CGFloat(20*UIScreen.main.scale);
        let settingsButtonFrame = CGRect(x: 0, y: topSafeAreaInsetHeight + 2*settingsButtonHeight, width: settingsButtonHeight/3, height: settingsButtonHeight);
        settingsButton.frame = settingsButtonFrame;
        settingsButton.backgroundColor = BackgroundColor;
        settingsButton.roundCorners(corners: [.topRight, .bottomRight], radius: settingsButtonHeight/6);
        
        settingsButton.clipsToBounds = true;
        settingsButton.setImage(UIImage(systemName: "chevron.right"), for: .normal);
        settingsButton.imageView?.contentMode = .scaleToFill;
        settingsButton.imageView?.tintColor = InverseBackgroundColor;
        //settingsButton.layer.cornerRadius = settingsButtonWidth/2;
        
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
                        //print("iteration");
                        
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
    
    
    // for keyboard stuff
    
    
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil);
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil);
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification: notification);
            //hamBurgMenuScrollView.frame.origin.y -= lastKeyboardOffset;
            hamBurgMenuScrollViewHeightConstraint.constant -= lastKeyboardOffset;
            keyboardAdjusted = true;
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            //hamBurgMenuScrollView.frame.origin.y += lastKeyboardOffset;
            hamBurgMenuScrollViewHeightConstraint.constant += lastKeyboardOffset;
            keyboardAdjusted = false;
        }
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo;
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue;
        return keyboardSize.cgRectValue.height;
    }
    
    //
    
    
    
}

