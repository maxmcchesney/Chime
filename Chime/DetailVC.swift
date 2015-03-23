//
//  DetailVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/3/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit



// 
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // set labels for selected venue
        selectedVenue = ChimeData.mainData().selectedVenue
        
        venueNameLabel.text = selectedVenue["venueName"] as? String
        venueNeighborhoodLabel.text = selectedVenue["venueNeighborhood"] as? String
        venuePhoneLabel.text = selectedVenue["venuePhone"] as? String
        
        // pass selected venue and deals to tvc
        dealsTVC.selectedVenue = selectedVenue
        if let deals = selectedVenue["venueDeals"] as? [[String:AnyObject]] {
            venueDeals = deals
            dealsTVC.venueDeals = deals
            if deals.count > 0 {
                instructionLabel.text = "chime in to start the clock and start saving. when the timer reaches the deals' required time, the deal will become available. just show your phone to your server to collect your reward!"
            }
        }
        
        dealsTV.reloadData()
        
        // hide toolbar
        
        navigationController?.toolbarHidden = true
        
        // remove drink images from navbar (optional)
        for image in navImageViews {
            image.removeFromSuperview()
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        
        refreshSelectedVenue()
        selectedVenue = ChimeData.mainData().selectedVenue
        
    }
    
    func refreshSelectedVenue() {
        // refresh the selected venue to reflect any added deals
        
        ChimeData.mainData().refreshSelectedVenueFromParse { () -> () in
            
            self.selectedVenue = ChimeData.mainData().selectedVenue
            
            self.dealsTVC.selectedVenue = self.selectedVenue
            if let deals = self.selectedVenue["venueDeals"] as? [[String:AnyObject]] {
                self.dealsTVC.venueDeals = deals
            }
            
            self.dealsTV.reloadData()
            
        }
        
    }
    
    func toggleCheckInButton() {
    
        if ChimeData.mainData().startTime > 0 || ChimeData.mainData().timerIsRunning {
                
            checkInButton.enabled = false
            
            // change appearance of checkIn button to disabled
            checkInButton.setTitle("checked In, enjoy!", forState: UIControlState.Disabled)
            
            // neither of these is working...
            checkInButton.setNeedsDisplay()
            view.setNeedsDisplay()
            
        } else {
            
            checkInButton.enabled = true
            checkInButton.setNeedsDisplay()
            
        }
        
    }

    /////////
    /////////   TIMER
    /////////
    
    var timer = NSTimer()
    var startTime = NSTimeInterval()

    var dealTime = NSTimeInterval()

    var geoPoint: PFGeoPoint?
    var location: CLLocation?

    var dealThresholds = []
    
    @IBAction func checkIn(sender: AnyObject) {
        
        if venueDeals.count == 0 {
            
            // venue doesn't have any deals set up, present alert to user
            var alertViewController = UIAlertController(title: "We're sorry!", message: "This venue doesn't have any active deals right now, please check back soon!", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)
            
            return
        }
        
        if ChimeData.mainData().timerIsRunning { return }
        
        let userInsideVenueRadius = checkUserDistanceFromVenue()
        
        // TODO: trigger some sort of observer to stop the timer / deals when the user exits the venue radius
        
        if userInsideVenueRadius {
            
            // start timer
            ChimeData.mainData().timerIsRunning = true
            ChimeData.mainData().checkedInVenue = selectedVenue
            
            let aSelector: Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            
            // check singleton for startTime, if nil, set it here
            if ChimeData.mainData().startTime > 0 {
                startTime = ChimeData.mainData().startTime
            } else {
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
            
            for deal in venueDeals {
                
                let active: Bool = deal["active"] as Bool
                
                if active {
                    
                    let time = deal["timeThreshold"] as NSString
                    let rewardDescription = deal["rewardDescription"] as String
                    
                    // convert time from hours (string) to seconds (double) and set notifications
                    let dealThreshold: NSTimeInterval = time.doubleValue * 10 // change this to * 60 * 60 for production
                    
                    let fireDate = NSDate(timeInterval: dealThreshold, sinceDate: NSDate())
                    println("Setting local notification for deal \(deal), at time threshold \(time).")
                    setLocalNotification(fireDate, andAlert: rewardDescription)
                    
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

            let venueRadius: CLLocationDistance = 500   // measured in meters
            
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
    
    func setLocalNotification(fireDate: NSDate, andAlert alert: String) {
        
        var notification = UILocalNotification()
        notification.category = "FIRST_CATEGORY"
        notification.alertBody = "You did it! Claim your prize: \(alert)"
        notification.fireDate = fireDate
//        notification.userInfo = 
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
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
    
    override func viewWillAppear(animated: Bool) {
        
        println("Selected Venue ID: \(ChimeData.mainData().selectedVenue?.objectId) | Checked In Venue ID: \(ChimeData.mainData().checkedInVenue?.objectId)")
        
        // retrieve startTime from Singleton if it's saved
        if ChimeData.mainData().startTime > 0 {
            
            if ChimeData.mainData().checkedInVenue?.objectId == selectedVenue.objectId {
                
                timerLabel.text = ChimeData.mainData().timeLabel    // works but causes time to jump the difference
                checkIn(self)
                
            } else {
                
                self.checkInButton.setTitle("you're elsewhere..", forState: UIControlState.Disabled)
            }

        }
        
        // check to see if a venue has been checked in to and if this is that venue
//        if ChimeData.mainData().checkedInVenue == selectedVenue {
//            println("Selected Venue has been checked in to...")
//        }
        
    }

}

class DetailTVC: UITableViewController {
    
    var selectedVenue: PFObject!
    var venueDeals: [[String:AnyObject]] = []
    
    
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
        println("Deal count: \(venueDeals.count)")
        return venueDeals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dealCell", forIndexPath: indexPath) as DealCell
        
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
//            println(deal)
            
            let dealName = deal["rewardDescription"] as String
            let dealTime = deal["timeThreshold"] as String
            let dealValue = deal["estimatedValue"] as Int
            
            
            cell.tagTimeLabel.text = "\(dealTime) hr"
            cell.dealLabel.text = "\(dealName)"
//            cell.tagValueLabel.text = 
            
        }
        
        return cell
    }
    
    // DOESN'T WORK
//    func dealClaimed(sender: DoubleCircleButton) {
//        println("deal claimed \(sender.tag)")
//        println("here's the issue...")
//        
//    }
    
}

