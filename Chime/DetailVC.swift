//
//  DetailVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/3/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

let blueActivated = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1)

class DetailVC: UIViewController {

    @IBOutlet weak var dealsTV: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var checkInButton: DesignableButton!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueNeighborhoodLabel: UILabel!
    @IBOutlet weak var venuePhoneLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var dealsTVC = DetailTVC()

    var selectedVenue: PFObject!
    var venueDeals: [[String:AnyObject]] = []
    
//    var audioPlayer = AVAudioPlayer()
    var soundID:SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let filePath = NSBundle.mainBundle().pathForResource("Tock", ofType: "aif") {
//            let fileURL = NSURL(fileURLWithPath: filePath)
//        }
//
//            audioPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
//            audioPlayer.prepareToPlay()
//        }
        
        // Get the main bundle for the app
        let mainBundle = CFBundleGetMainBundle()
//        let cfName =
        let soundFileURLRef = CFBundleCopyResourceURL(mainBundle, "tap", "aif", nil)

        AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID)
        
        
        // if already checkedIn ...  checkInButton.enabled = false
        toggleCheckInButton()
        
        // set bgimage here as well b/c transparency caused animation issues
        let bgImageView = UIImageView(frame: CGRectMake(0, -65, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        let bgImage = UIImage(named: "bgGradient")
        bgImageView.image = bgImage
        view.insertSubview(bgImageView, atIndex: 0)

        // set labels for selected venue
        selectedVenue = ChimeData.mainData().selectedVenue

        venueNameLabel.text = selectedVenue["venueName"] as? String
        venueNeighborhoodLabel.text = selectedVenue["venueNeighborhood"] as? String
        
        // set tableview delegate and data source
        dealsTV.delegate = dealsTVC
        dealsTV.dataSource = dealsTVC
        dealsTVC.vc = self
        
        // set labels for selected venue
        selectedVenue = ChimeData.mainData().selectedVenue
        
        venueNameLabel.text = selectedVenue["venueName"] as? String
        venueNeighborhoodLabel.text = selectedVenue["venueNeighborhood"] as? String
        venuePhoneLabel.text = selectedVenue["venuePhone"] as? String
        
        // pass selected venue and deals to tvc
        dealsTVC.selectedVenue = selectedVenue
        if let deals = selectedVenue["venueDeals"] as? [[String:AnyObject]] {
            
            for deal in deals {
                let status: Bool = deal["active"] as! Bool
                if !status {
                    // remove the deal before passing it to tableview
                }
            }
            
            venueDeals = deals
            dealsTVC.venueDeals = deals
            if deals.count > 0 {
                instructionLabel.text = "Chime in to start the clock. When the timer reaches a deal's threshold, it will become available. Just show your phone to your server to collect your reward!"
            }
        }
        
        dealsTV.reloadData()
        
        // hide toolbar
        navigationController?.toolbarHidden = true
        
        // remove drink images from navbar (optional)
        for image in navImageViews {
            image.removeFromSuperview()
        }
        
        // add observer for notification center when deal is activated
        NSNotificationCenter.defaultCenter().addObserverForName("dealActivated", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
//            println("RECEIVED NOTIFICATION::: \(notification)")
            let activatedDeal = notification.userInfo as! [String:AnyObject]
            ChimeData.mainData().activatedDeals.append(activatedDeal)
            self.dealsTV.reloadData()
            self.makeVibrate()
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        
        refreshSelectedVenue()
        selectedVenue = ChimeData.mainData().selectedVenue
        
        checkStartTimeAgainstDeals()
        
        // set the badge icon to 0
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        badgeNumber = 0
        
        // ANIMATIONS
        
        // animate the name from the top
        var scale1 = CGAffineTransformMakeScale(0.5, 0.5)
        var translate1 = CGAffineTransformMakeTranslation(0, -150)
        self.venueNameLabel.transform = CGAffineTransformConcat(scale1, translate1)
        
        animationWithDuration(1.5) {
            self.venueNameLabel.hidden = false
            var scale = CGAffineTransformMakeScale(1, 1)
            var translate = CGAffineTransformMakeTranslation(0, 0)
            self.venueNameLabel.transform = CGAffineTransformConcat(scale, translate)
        }
        
        // animate the neighborhood and phone labels from the
        var scale2 = CGAffineTransformMakeScale(0.5, 0.5)
        var translate2 = CGAffineTransformMakeTranslation(0, 150)
        self.venueNeighborhoodLabel.transform = CGAffineTransformConcat(scale2, translate2)
        self.venuePhoneLabel.transform = CGAffineTransformConcat(scale2, translate2)
        
        animationWithDuration(1.25) {
            self.venueNeighborhoodLabel.hidden = false
            self.venuePhoneLabel.hidden = false
            var scale = CGAffineTransformMakeScale(1, 1)
            var translate = CGAffineTransformMakeTranslation(0, 0)
            self.venueNeighborhoodLabel.transform = CGAffineTransformConcat(scale, translate)
            self.venuePhoneLabel.transform = CGAffineTransformConcat(scale, translate)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // hide stuff for animations
        venueNameLabel.hidden = true
        venueNeighborhoodLabel.hidden = true
        venuePhoneLabel.hidden = true
        
        
        // retrieve startTime from Singleton if it's saved
        if ChimeData.mainData().startTime > 0 {
            
            if ChimeData.mainData().checkedInVenue?.objectId == selectedVenue.objectId {
                
                timerLabel.text = ChimeData.mainData().timeLabel    // works but causes time to jump the difference
                //                checkIn(self)
                
                checkTimer()
                
            } else {
                
                self.checkInButton.setTitle("You're not here..", forState: UIControlState.Disabled)
            }
            
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        // save startTime to Singleton for when user navigates away from detailVC
        if startTime > 0 {
            
            ChimeData.mainData().startTime = startTime
            ChimeData.mainData().timeLabel = timerLabel.text!
            timer.invalidate()
            ChimeData.mainData().timerIsRunning = false
            
        }
        
    }
    
    
    func refreshSelectedVenue() {
        // refresh the selected venue to reflect any added deals
        
        ChimeData.mainData().refreshSelectedVenueFromParse { () -> () in
            
            self.selectedVenue = ChimeData.mainData().selectedVenue
            
            self.dealsTVC.selectedVenue = self.selectedVenue
            
            if let deals = self.selectedVenue["venueDeals"] as? [[String:AnyObject]] {
                
                self.dealsTVC.venueDeals = []
                
//                 TODO: If deal is inactive, remove it from the dictionary before passing it to the TV
                for deal in deals {
                    
                    if let status: Bool = deal["active"] as? Bool {
                        
                        if status {
                            
                            self.dealsTVC.venueDeals.append(deal)
                            
                        }
                        
                    }
                }
                
            }
            
            self.dealsTV.reloadData()
            
        }
        
    }
    
    func toggleCheckInButton() {
    
        if ChimeData.mainData().startTime > 0 || ChimeData.mainData().timerIsRunning {
                
            checkInButton.enabled = false
            
            // change appearance of checkIn button to disabled with animation
            
            // animate the logo from the bottom
            var scale1 = CGAffineTransformMakeScale(1.5, 1.5)
            var translate1 = CGAffineTransformMakeTranslation(0, 0)
            checkInButton.titleLabel?.transform = CGAffineTransformConcat(scale1, translate1)
            
            animationWithDuration(2) {
                var scale = CGAffineTransformMakeScale(1, 1)
                var translate = CGAffineTransformMakeTranslation(0, 0)
                self.checkInButton.titleLabel?.transform = CGAffineTransformConcat(scale, translate)
            }
            
            checkInButton.setTitle("Chimed in, enjoy!", forState: UIControlState.Disabled)
            
            checkInButton.setNeedsDisplay()
            view.setNeedsDisplay()
            
        } else {
            
            checkInButton.enabled = true
            checkInButton.setNeedsDisplay()
            
        }
        
    }
    
    // CREATE SOUNDS AND VIBRATE WHEN CHECKING IN
    // TODO: SOUND DOESNT WORK
    func playChime() {

        if let path = NSBundle.mainBundle().pathForResource("Tock", ofType: "aif") {
            let URL = NSURL(fileURLWithPath: path)
            
            var sID = SystemSoundID()
            AudioServicesCreateSystemSoundID(URL, &sID)
            
            AudioServicesPlayAlertSound(sID)
            
        }
        
    }
    
    // make phone vibrate
    func makeVibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }


    /////////
    /////////   TIMER / CHECK IN
    /////////
    
    var timer = NSTimer()
    var startTime = NSTimeInterval()

    var dealTime = NSTimeInterval()

    var geoPoint: PFGeoPoint?
    var location: CLLocation?
    
    @IBAction func checkIn(sender: AnyObject) {
        
        if venueDeals.count == 0 {
            
            // venue doesn't have any deals set up, present alert to user
            var alertViewController = UIAlertController(title: "We're sorry!", message: "This venue doesn't have any active deals right now, please check back soon!", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)
            
            return
        }
        
        if ChimeData.mainData().timerIsRunning || ChimeData.mainData().startTime > 0 { return }
        
        let userInsideVenueRadius = checkUserDistanceFromVenue()
        
        /////////
        /////////   CHECK IF USER IS WITHIN THE RADIUS OF VENUE
        /////////
        if userInsideVenueRadius {
            
            // make sound and vibrate
            makeVibrate()
            playChime()
            
            // start timer
            ChimeData.mainData().timerIsRunning = true
            ChimeData.mainData().checkedInVenue = selectedVenue
            
            // check if it was running previously
            checkTimer()
            
            for deal in venueDeals {
                
                let active: Bool = deal["active"] as! Bool
                
                if active {
                    
                    let time = deal["timeThreshold"] as! NSString
                    let rewardDescription = deal["rewardDescription"] as! String
                    
                    // convert time from hours (string) to seconds (double) and set notifications
                    let dealThreshold: NSTimeInterval = time.doubleValue * 10 // change this to * 60 * 60 for production
                    
                    let fireDate = NSDate(timeInterval: dealThreshold, sinceDate: NSDate())
                    println("Setting local notification for deal \(deal), at time threshold \(time).")
//                    setLocalNotification(fireDate, andAlert: rewardDescription)
                    setLocalNotification(fireDate, andAlert: rewardDescription, andDeal: deal)
                    
                    toggleCheckInButton()
                    
                }
                
            }
            
        } else {
            
            // user isn't close enough to venue, present alert
            var alertViewController = UIAlertController(title: "You In The Right Spot?", message: "Looks like you're not close enough to the venue to check in...make sure you're in the right location and try again!", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)

            return
        }
        
    }
    
    func checkUserDistanceFromVenue() -> Bool {
        
        // CHECK TO SEE IF USER IS WITHIN SOME DISTANCE OF THE VENUE
        var userLocation = GlobalVariableSharedInstance.currentLocation() as CLLocation
        
        if let venueLocation = self.location as CLLocation? {
            
            let userDistanceFromVenue = userLocation.distanceFromLocation(venueLocation)

            let venueRadius: CLLocationDistance = 500   // measured in meters, CHANGE THIS FOR PRODUCTION
            
            if userDistanceFromVenue <= venueRadius {
                
                println("User is within Venue Radius, running the timer...")
                return true
                
            } else {
                
                println("User is not within Venue Radius...")
                return false
            }
        
        } else {
            println("Error retrieving venue location...")
            return false
        }
    }
    
    func updateTime() {

        // CONTINUALLY CHECK TO SEE IF USER IS WITHIN SOME DISTANCE OF THE VENUE
        let userInsideVenueRadius = checkUserDistanceFromVenue()
        
        if !userInsideVenueRadius {
            // user isn't close enough to venue, present alert
            var alertViewController = UIAlertController(title: "Uh Oh!", message: "Looks like you've wandered too far from the venue... You have to stay put to run the clock!", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)
            
            makeVibrate()
            
            return
        }
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        // find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        // calculate the hours in elapsed time.
        let hours = UInt8(elapsedTime / 60 / 60)
        
        // calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        // calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        // add the leading zero for hours, minutes, and seconds and store them as string constants
        //        let strHours = hours > 9 ? String(hours):"0" + String(hours)
        let strHours = String(hours)
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        
        // concatenate hours, minutes, and seconds as assign it to the UILabel
        timerLabel.text = "\(strHours):\(strMinutes):\(strSeconds)"
        
    }
    
    func checkStartTimeAgainstDeals() {
        
        // don't check the deals if the timer isn't running, otherwise do...
        if ChimeData.mainData().timerIsRunning || startTime == 0 { return }
        
        for deal in venueDeals {
            
            let active: Bool = deal["active"] as! Bool
            
            if active {
                
                let time = deal["timeThreshold"] as! NSString
                
                // convert time from hours (string) to seconds (double) and set notifications
                let dealThreshold: NSTimeInterval = time.doubleValue * 10 // change this to * 60 * 60 for production
                
                var currentTime = NSDate.timeIntervalSinceReferenceDate()
                
                // find the difference between current time and start time.
                var elapsedTime: NSTimeInterval = currentTime - startTime
                
                println("dealthreshold: \(dealThreshold), elapsed time: \(elapsedTime)")

                if elapsedTime > dealThreshold {
                    
                    // deal should be activated, append to array of activated deals
                    ChimeData.mainData().activatedDeals.append(deal)
                    self.dealsTV.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    var badgeNumber: Int = 0
    
    func setLocalNotification(fireDate: NSDate, andAlert alert: String, andDeal deal: [String:AnyObject]) {
        
        badgeNumber++
        
        var notification = UILocalNotification()
        notification.category = "FIRST_CATEGORY"
        notification.alertBody = "You did it! Claim your prize: \(alert)"
        notification.fireDate = fireDate
        notification.userInfo = deal

        notification.applicationIconBadgeNumber = badgeNumber
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    func checkTimer() {
        let aSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        // check singleton for startTime, if nil, set it here
        if ChimeData.mainData().startTime > 0 {
            startTime = ChimeData.mainData().startTime
        } else {
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
}

class DetailTVC: UITableViewController {
    
    var selectedVenue: PFObject!
    var venueDeals: [[String:AnyObject]] = []
    
    var vc: DetailVC!
    
//    var activatedDeals: [[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    /////////
    /////////   CONFIGURE TABLEVIEW
    /////////
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venueDeals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dealCell", forIndexPath: indexPath) as! DealCell
        
        // Configure the cell...
        
        // set up the cell coloring
        let lighterColor: UIColor = UIColor(red:0.71, green:0.87, blue:0.55, alpha:0.5)
        let middleColor: UIColor = UIColor(red:0.56, green:0.78, blue:0.35, alpha:0.5)
        let darkerColor: UIColor = UIColor(red:0.43, green:0.62, blue:0.25, alpha:0.5)
        let cellColors = [middleColor, darkerColor, lighterColor]
        /// OPTIONAL: change to % 3 for tri-coloring
        cell.backgroundColor = cellColors[indexPath.row % 2]
        cell.tagView.backgroundColor = cellColors[indexPath.row % 2].colorWithAlphaComponent(0.9)
        
        if let deals = selectedVenue["venueDeals"] as? [[String:AnyObject]] {
            
            let deal = deals[indexPath.row]
            
            let dealName = deal["rewardDescription"] as! String
            let dealTime = deal["timeThreshold"] as! String
            let dealValue = deal["estimatedValue"] as! Int
            
            cell.tagTimeLabel.text = "\(dealTime) hr"
            cell.dealLabel.text = "\(dealName)"
            
            if dealValue >= 50 {
                cell.tagValueLabel.text = "$50+"
            } else {
                cell.tagValueLabel.text = "$\(dealValue)"
            }
            
            // check if deal is activated and present in activatedDeals array
            for aD in ChimeData.mainData().activatedDeals {
                if NSDictionary(dictionary: deal) == aD {

                    cell.tagView.backgroundColor = blueActivated
//                    cell.indicatorArrow.strokeColor = blueActivated
                    cell.indicatorArrow.hidden = false
                    cell.layer.borderColor = UIColor.blueColor().colorWithAlphaComponent(0.3).CGColor
                    cell.layer.borderWidth = 1
                    cell.indicatorArrow.setNeedsDisplay()
                    cell.claimInstructionsLabel.hidden = false
                    cell.dealLabel.text = "CLAIM: \(dealName)"
                    
                    // animate the scale of the deal label
                    var scale1 = CGAffineTransformMakeScale(2, 2)
                    var translate1 = CGAffineTransformMakeTranslation(0, 0)
                    cell.dealLabel.transform = CGAffineTransformConcat(scale1, translate1)
                    cell.indicatorArrow.transform = CGAffineTransformConcat(scale1, translate1)
                    cell.claimInstructionsLabel.transform = CGAffineTransformConcat(scale1, translate1)
                    
                    spring(2) {
                        
                        var scale = CGAffineTransformMakeScale(1, 1)
                        var translate = CGAffineTransformMakeTranslation(0, 0)
                        cell.dealLabel.transform = CGAffineTransformConcat(scale, translate)
                        cell.indicatorArrow.transform = CGAffineTransformConcat(scale, translate)
                        cell.claimInstructionsLabel.transform = CGAffineTransformConcat(scale, translate)
                        
                    }
                    
                }
                
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        if let deals = selectedVenue["venueDeals"] as? [[String:AnyObject]] {
            
            let deal = deals[indexPath.row]

            if let status: Bool = deal["active"] as? Bool {
                
                if status {
                    
                    var alertViewController = UIAlertController(title: "Claim Deal", message: "Show this to your server to redeem your reward!", preferredStyle: UIAlertControllerStyle.Alert)
                    var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alertViewController.addAction(defaultAction)
                    vc.presentViewController(alertViewController, animated: true, completion: nil)
                    
                }
                
            }

        }
        
    }
    
}

