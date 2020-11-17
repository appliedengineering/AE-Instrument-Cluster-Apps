//
//  ViewController.swift
//  IOS-inst-clstr
//
//  Created by Richard Wei on 10/12/20.
//

import UIKit
import MessagePacker
import AudioToolbox
import Charts

let protocolString = "udp";
var connectionIPAddress = "";
var connectionPort = "";
var connectionAddress = "";
var connectionGroup = "";
var receiveReconnect = -1; // in ms
var receiveTimeout = -1; // in ms

// bufferSize is defined as graphs.bufferSize

var reconnectTimeout = -1; // in sec


let communication = communicationClass.obj;
let dataMgr = dataManager.obj;
let graphs = graphManager.obj;
let errors = errorManager.obj;

class mainViewClass: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate {

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
    

    let scrollViewFadeButtonThresholdHeight = CGFloat(100);
    let settingsButton = UIButton();

    
    // textfields needed to submit in settings
    let ipAddressInput = UITextField();
    let connectionPortInput = UITextField();
    let connectionGroupInput = UITextField();
    let receiveReconnectInput = UITextField(); // in ms
    let receiveTimeoutInput = UITextField(); // in ms
    let reconnectTimeoutInput = UITextField(); // in sec
    let bufferSizeInput = UITextField(); // in units of data points
    // end textfields

    func loadPreferences(){
        //connectionIPAddress = "224.0.0.1"; // defaults
        //connectionPort = "28650"; // defaults
        //connectionGroup = "telemetry"; // defaults
        //recieveTimeout = 1000; // defaults
        //reconnectTimeout = 3; // defaults
        // load user pref
        
        connectionIPAddress = UserDefaults.standard.string(forKey: "connectionIPAddress") ?? "224.0.0.1";
        connectionPort = UserDefaults.standard.string(forKey: "connectionPort") ?? "28650";
        connectionGroup = UserDefaults.standard.string(forKey: "connectionGroup") ?? "telemetry";
        receiveReconnect = UserDefaults.standard.integer(forKey: "receiveReconnect") == 0 ? 1000 : UserDefaults.standard.integer(forKey: "receiveReconnect");
        receiveTimeout = UserDefaults.standard.integer(forKey: "receiveTimeout") == 0 ? 100 : UserDefaults.standard.integer(forKey: "receiveTimeout");
        reconnectTimeout = UserDefaults.standard.integer(forKey: "reconnectTimeout") == 0 ? 3 : UserDefaults.standard.integer(forKey: "reconnectTimeout");
        graphs.bufferSize = UserDefaults.standard.integer(forKey: "bufferSize") == 0 ? 100 : UserDefaults.standard.integer(forKey: "bufferSize");
        
        connectionAddress = protocolString + "://" + connectionIPAddress + ":" + connectionPort;
    }
    
    
    // MARK: UI FUNCTIONS

    
    // SFProDisplay-Regular, SFProDisplay-Semibold, SFProDisplay-Black, SFProText-Bold
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view
        self.hideKeyboardWhenTappedAround();
        
        loadPreferences();
        //printAllFonts();
        
        
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
        let settingsButtonFrame = CGRect(x: 0, y: AppUtility.topSafeAreaInsetHeight, width: settingsButtonHeight/3, height: settingsButtonHeight);
        settingsButton.frame = settingsButtonFrame;
        settingsButton.backgroundColor = BackgroundColor;
        settingsButton.roundCorners(corners: [.topRight, .bottomRight], radius: settingsButtonHeight/6);
        
        settingsButton.clipsToBounds = true;
        settingsButton.setImage(UIImage(systemName: "chevron.right"), for: .normal);
        settingsButton.imageView?.contentMode = .scaleToFill;
        settingsButton.imageView?.tintColor = InverseBackgroundColor;
        //settingsButton.layer.borderWidth = 1;
        //settingsButton.layer.borderColor = InverseBackgroundColor.cgColor;
        //settingsButton.layer.cornerRadius = settingsButtonWidth/2;
        
        settingsButton.addTarget(self, action: #selector(toggleHamBurgMenu), for: .touchUpInside);
        
        mainView.addSubview(settingsButton);
   
        mainScrollView.tag = -1;
        //mainScrollView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1).isActive = true;
        mainScrollView.delegate = self;
        mainScrollView.showsVerticalScrollIndicator = false;
        mainScrollView.showsHorizontalScrollIndicator = false;
        
        renderViews();
        
        if (!communication.connect(connectionstr: connectionAddress, connectionGroup: connectionGroup, recvReconnect: receiveReconnect)){
            print("failed first connection - check settings and reconnect again")
        }
        
        communicationThread();
    }
    
    
    
    func renderViews(){
        
        for view in mainScrollView.subviews{
            if (view.tag == 1){
                view.removeFromSuperview();
            }
        }
        let screenWidth = UIScreen.main.bounds.width;
        let verticalPadding = CGFloat(20);
        var nextY = CGFloat(0);
    
        let headerViewHeight = CGFloat(50);
        let headerViewFrame = CGRect(x: 0, y: nextY, width: UIScreen.main.bounds.width, height: headerViewHeight);
        let headerView = UIView(frame: headerViewFrame);
        
        headerView.backgroundColor = BackgroundColor;
        
        let appIconViewVerticalPadding = CGFloat(5);
        let appIconViewSide = CGFloat(headerViewHeight - 2*appIconViewVerticalPadding);
        let appIconViewFrame = CGRect(x: (headerViewFrame.size.width / 2) - (appIconViewSide / 2), y: appIconViewVerticalPadding, width: appIconViewSide, height: appIconViewSide);
        let appIconView = UIImageView(frame: appIconViewFrame);
        appIconView.image = UIImage(named: "AELogo");
        appIconView.contentMode = .scaleAspectFill;
        
        headerView.addSubview(appIconView);
        nextY += headerViewHeight;
        mainScrollView.addSubview(headerView);
    
        
        //let dataStreamColors = [rgb(r: 216,g: 67,b: 21), rgb(r: 33,g: 150,b: 243), rgb(r: 76,g: 175,b: 80), rgb(r: 255,g: 152,b: 0), rgb(r: 244,g: 67,b: 54)];
        let dataStreamViewHeight = CGFloat(screenWidth * 0.5333);
        for i in 0..<graphs.numOfGraphs{
            let dataStreamViewFrame = CGRect(x: 0, y: nextY, width: screenWidth, height: dataStreamViewHeight);
            let dataStreamView = GraphUIButton(frame: dataStreamViewFrame);
            /*dataStreamView.backgroundColor = UIColor.blue;
            
            dataStreamView.clipsToBounds = true;
            
            let currentTitle = graphs.graphNameArray[i];
            let titleTextFont = UIFont(name: "SFProDisplay-Semibold", size: 18)!;
            let innerPadding = CGFloat(20);
            let titleTextFrame = CGRect(x: innerPadding, y: innerPadding, width: dataStreamViewFrame.width, height: currentTitle.getHeight(withConstrainedWidth: screenWidth, font: titleTextFont));
            let titleText = UILabel(frame: titleTextFrame);
            titleText.font = titleTextFont;
            titleText.text = currentTitle;
            
            dataStreamView.addSubview(titleText);*/
    
            let currentGraph = LineChartView(frame: CGRect(x: 0, y: 0, width: dataStreamViewFrame.width, height: dataStreamViewFrame.height));
            //currentGraph.frame = CGRect(x: 0, y: 0, width: dataStreamViewFrame.width, height: dataStreamViewFrame.height);
            
            currentGraph.backgroundColor = UIColor.clear;
            currentGraph.isUserInteractionEnabled = false;
            currentGraph.xAxis.drawGridLinesEnabled = false;
            currentGraph.leftAxis.drawAxisLineEnabled = false;
            currentGraph.leftAxis.drawGridLinesEnabled = false;
            //currentGraph.leftAxis.axisLineColor = UIColor.clear;
            currentGraph.rightAxis.drawAxisLineEnabled = false;
            currentGraph.legend.enabled = false;
            currentGraph.rightAxis.enabled = false;
            //currentGraph.leftAxis.enabled = false;
            currentGraph.xAxis.enabled = false;
            currentGraph.drawGridBackgroundEnabled = false;
            
            let line = LineChartDataSet(entries: [ChartDataEntry](), label: graphs.graphNameArray[i]);
            
            // set line attributes here
            //print("color - \(graphs.graphColorArray[i])")
            line.fill = Fill.fillWithLinearGradient(CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [graphs.graphColorArray[i].cgColor, UIColor.clear.cgColor] as CFArray, locations: [1.0, 0.0])!, angle: 90.0);
            line.drawFilledEnabled = true;
            line.drawCirclesEnabled = false;
            line.drawValuesEnabled = false;
            line.colors = [graphs.graphColorArray[i]];
            //line.valueFont = UIFont(name: "SFProDisplay-Regular", size: 10)!;
            //line.mode = .cubicBezier;
            
            // end line attributes
            
            let lineData = LineChartData();
            
            lineData.addDataSet(line);
            
            currentGraph.data = lineData;
            
            graphs.graphViews.append(currentGraph);
            
            dataStreamView.addSubview(currentGraph);
            
            let graphTitleFont = UIFont(name: "SFProDisplay-Semibold", size: 18)!;
            let graphTitleHeight = currentGraph.frame.height / 8;
            let graphTitleWidth = graphs.graphNameArray[i].getWidth(withConstrainedHeight: graphTitleHeight, font: graphTitleFont);
            let graphTitleFrame = CGRect(x: currentGraph.frame.width - graphTitleWidth - (currentGraph.frame.width / 25), y: 0, width: graphTitleWidth, height: graphTitleHeight);
            let graphTitle = UILabel(frame: graphTitleFrame);
            graphTitle.text = graphs.graphNameArray[i];
            graphTitle.font = graphTitleFont;
            graphTitle.textColor = InverseBackgroundColor;
            
            dataStreamView.addSubview(graphTitle);
            //}
            
            dataStreamView.addTarget(self, action: #selector(openGraphView), for: .touchUpInside);
            dataStreamView.graphIndex = i;
            
            mainScrollView.addSubview(dataStreamView);
            
            nextY += dataStreamViewHeight + verticalPadding;
        }
        
        mainScrollView.contentSize = CGSize(width: screenWidth, height: nextY);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mainViewTographViewSegue"){
            let vc = segue.destination as! graphViewClass;
            vc.graphIndex = sender as! Int;
        }
    }
    
    @objc func openGraphView(button: GraphUIButton){
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
        //print("open graph view - \(button.graphIndex)")
        performSegue(withIdentifier: "mainViewTographViewSegue", sender: button.graphIndex);
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.tag == -1){
            let scrollContentYPercent = min(1, max(1 - ((scrollView.contentOffset.y + AppUtility.topSafeAreaInsetHeight) / scrollViewFadeButtonThresholdHeight), 0)); // some maths
            //print("scroll content offset = \(scrollView.contentOffset.y) : \(scrollContentYPercent)")
            settingsButton.alpha = scrollContentYPercent;
        }
    }
    
    /*override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // rerender homescreen
        print("changed orientation");
        renderViews();
    }*/
    
    // MARK: END UI FUNCS
    
    
    
    
    // MARK: MULTITHREAD FUNC
    
    func communicationThread(){
        // use multithreading to get the actual data from communication.swift then use main thread to set ui elements
        DispatchQueue.global(qos: .background).async{
            while true{ // keeps on reconnecting

                while communication.dish != nil{
                    //print("iteration");
                    
                    do{
                        
                        let data = try MessagePackDecoder().decode(APiDataPack.self, from: try communication.dish?.recv(options: .none) ?? Data());
                        //print("test")
                        //print("recieved data - \(data)");
                        dataMgr.updateWithNewData(data: data);
                        //print(graphs.graphViews[0].data!.dataSets[0].entryCount)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateGraph"), object: nil);
                        usleep(useconds_t(receiveTimeout * 1000)); // ms
                        
                     }
                    catch {
                        //print("recieved catch - \(error)") // -- toggling this print func allows the recieve to work and not work for some reason
                        if ("\(error)" != "Resource temporarily unavailable"){ // super hacky but it works lmao
                            print("Communication recieve error - \(error)");
                        }
                        errors.addErrorToBuffer(error: errorData(description: "\(error)", timeStamp: errors.createTimestampStruct()));
                    }
                    
                    
                }
  
                //print("before sleep")
                sleep(UInt32(reconnectTimeout));
                //print("after sleep")
            }
        }
    }
    
    
    
    // MARK: MULTITHREAD FUNC END
    
    
    
    
    // MARK: HamBurg menu funcs and vars ----------------------------------------------------------------------------------------------------------------------
    
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
        dismissKeyboard();
        enableHamBurgMenu = true;
        //self.hamBurgMenuViewLeadingConstraint.constant = 0;
        UIView.animate(withDuration: 0.2){
            self.hamBurgMenuViewLeadingConstraint.constant = 0;
            self.view.layoutIfNeeded();
        }
    }
    
    func closeHamBurgMenu(){
        dismissKeyboard();
        enableHamBurgMenu = false;
        //self.hamBurgMenuViewLeadingConstraint.constant = -self.hamBurgMenuViewWidth;
        UIView.animate(withDuration: 0.2){
            self.hamBurgMenuViewLeadingConstraint.constant = -self.hamBurgMenuViewWidth; // const
            self.view.layoutIfNeeded();
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) { // main goal is to set the hamburgmenuconstraint
        dismissKeyboard();
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
        if (validateIpAddress(ipToValidate: ipAddressInput.text ?? "") && connectionPortInput.text?.count ?? 0 > 0 && connectionGroupInput.text?.count ?? 0 > 0){
            UserDefaults.standard.set(ipAddressInput.text ?? "", forKey:"connectionIPAddress");
            UserDefaults.standard.set(connectionPortInput.text ?? "", forKey:"connectionPort");
            UserDefaults.standard.set(connectionGroupInput.text ?? "", forKey:"connectionGroup");
            UserDefaults.standard.set(Int(receiveTimeoutInput.text ?? "0"), forKey:"receiveTimeout");
            UserDefaults.standard.set(Int(receiveReconnectInput.text ?? "0"), forKey:"receiveReconnect");
            UserDefaults.standard.set(Int(reconnectTimeoutInput.text ?? "0"), forKey:"reconnectTimeout");
            UserDefaults.standard.set(Int(bufferSizeInput.text ?? "0"), forKey:"bufferSize");
            
            loadPreferences();
            
            renderHamBurgMenu();
            
            //hamBurgMenuScrollView.setContentOffset(.zero, animated: true);
            
            if (!communication.newconnection(connectionstr: connectionAddress, connectionGroup: connectionGroup, recvReconnect: receiveReconnect)){
                print("FAILED TO CONNECT TO NEW ADDRESS")
            }
            else {
                print("successful connection to new address")
                UIImpactFeedbackGenerator(style: .light).impactOccurred();
                closeHamBurgMenu();
            }
        }
        else{
            /*print("ip - \(validateIpAddress(ipToValidate: ipAddressInput.text ?? ""))")
            print("connection port - \(connectionPortInput.text?.count)")
            print("connection group - \(connectionGroupInput.text?.count)")*/
            print("Invalid settings - check your settings and make sure everything is correct");
        }
    }
    
    @objc func openErrorLog(){
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
        performSegue(withIdentifier: "mainViewToerrorViewSegue", sender: nil);
    }
    
    func renderHamBurgMenu(){
        // ham burg menu rendering stuff
        // we won't have to rerender this menu because it only takes in stuff for addresses and crap
        
        for subview in hamBurgMenuScrollView.subviews{
            if (subview.tag == 1){
                subview.removeFromSuperview();
            }
        }
        
        var nextY = AppUtility.topSafeAreaInsetHeight;
        
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
        
        /// ----------- RECIEVE RECONNECT
        
        let receiveReconnectLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let receiveReconnectLabel = UILabel(frame: receiveReconnectLabelFrame);
        receiveReconnectLabel.text = "Receive Reconnect (ms)";
        receiveReconnectLabel.textColor = InverseBackgroundColor;
        receiveReconnectLabel.textAlignment = .left;
        receiveReconnectLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        receiveReconnectLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(receiveReconnectLabel);
        nextY += receiveReconnectLabelFrame.height;
        
        let receiveReconnectInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        receiveReconnectInput.frame = receiveReconnectInputFrame; // already declared above
        receiveReconnectInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        receiveReconnectInput.text = String(receiveReconnect);
        receiveReconnectInput.allowsEditingTextAttributes = false;
        receiveReconnectInput.autocorrectionType = .no;
        receiveReconnectInput.spellCheckingType = .no;
        receiveReconnectInput.keyboardType = .numberPad; // experiment with this
        receiveReconnectInput.setUnderLine();
        receiveReconnectInput.delegate = self;
        receiveReconnectInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(receiveReconnectInput);
        nextY += receiveReconnectInputFrame.height + verticalPadding;
        
        /// ----------- RECIEVE TIMEOUT
        
        let receiveTimeoutLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let receiveTimeoutLabel = UILabel(frame: receiveTimeoutLabelFrame);
        receiveTimeoutLabel.text = "Receive Timeout (ms)";
        receiveTimeoutLabel.textColor = InverseBackgroundColor;
        receiveTimeoutLabel.textAlignment = .left;
        receiveTimeoutLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        receiveTimeoutLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(receiveTimeoutLabel);
        nextY += receiveTimeoutLabelFrame.height;
        
        let receiveTimeoutInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        receiveTimeoutInput.frame = receiveTimeoutInputFrame; // already declared above
        receiveTimeoutInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        receiveTimeoutInput.text = String(receiveTimeout);
        receiveTimeoutInput.allowsEditingTextAttributes = false;
        receiveTimeoutInput.autocorrectionType = .no;
        receiveTimeoutInput.spellCheckingType = .no;
        receiveTimeoutInput.keyboardType = .numberPad; // experiment with this
        receiveTimeoutInput.setUnderLine();
        receiveTimeoutInput.delegate = self;
        receiveTimeoutInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(receiveTimeoutInput);
        nextY += receiveTimeoutInputFrame.height + verticalPadding;
        
        
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
        
        /// ----------- BUFFER SIZE
        
        let bufferSizeLabelFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuTextHeight);
        let bufferSizeLabel = UILabel(frame: bufferSizeLabelFrame);
        bufferSizeLabel.text = "Data Buffer Size";
        bufferSizeLabel.textColor = InverseBackgroundColor;
        bufferSizeLabel.textAlignment = .left;
        bufferSizeLabel.font = UIFont(name: "SFProDisplay-Semibold", size: 20);
        bufferSizeLabel.tag = 1;
        
        hamBurgMenuScrollView.addSubview(bufferSizeLabel);
        nextY += bufferSizeLabelFrame.height;
        
        let bufferSizeInputFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: hamBurgMenuInputHeight);
        bufferSizeInput.frame = bufferSizeInputFrame; // already declared above
        bufferSizeInput.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        bufferSizeInput.text = String(graphs.bufferSize);
        bufferSizeInput.allowsEditingTextAttributes = false;
        bufferSizeInput.autocorrectionType = .no;
        bufferSizeInput.spellCheckingType = .no;
        bufferSizeInput.keyboardType = .numberPad; // experiment with this
        bufferSizeInput.setUnderLine();
        bufferSizeInput.delegate = self;
        bufferSizeInput.tag = 1;
        
        hamBurgMenuScrollView.addSubview(bufferSizeInput);
        nextY += bufferSizeInputFrame.height + verticalPadding;
        
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
        
        
        let openErrorLogButtonFrame = CGRect(x: horizontalPadding, y: nextY, width: hamBurgMenuSubViewWidth, height: 40);
        let openErrorLogButton = UIButton(frame: openErrorLogButtonFrame);
        openErrorLogButton.backgroundColor = BackgroundGray;
        openErrorLogButton.setTitle("Open Error Log", for: .normal);
        openErrorLogButton.setTitleColor(InverseBackgroundColor, for: .normal);
        openErrorLogButton.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 18);
        openErrorLogButton.titleLabel?.textAlignment = .center;
        openErrorLogButton.layer.cornerRadius = 4;
        openErrorLogButton.tag = 1;
        
        openErrorLogButton.addTarget(self, action: #selector(openErrorLog), for: .touchUpInside);
        
        hamBurgMenuScrollView.addSubview(openErrorLogButton);
        nextY += openErrorLogButtonFrame.height + verticalPadding;
        
        // END
        
        hamBurgMenuScrollView.contentSize = CGSize(width: hamBurgMenuViewWidth, height: nextY);
        
        hamBurgMenuScrollView.setContentOffset(.zero, animated: true);
        
        hamBurgMenuScrollView.delegate = self;
        
        // end ham burg menu rendering
    }
    
    // MARK: end HamBurg menu funcs and vars
    
    
    

    
    // MARK: KEYBOARD stuff
    
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }

    
    // MARK: END KEYBOARD -------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    
}

