//
//  VendorDetailVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/18/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class VendorDetailVC: UIViewController {

    @IBOutlet weak var dealsTV: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var checkInButton: DesignableButton!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueNeighborhoodLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var venuePhoneLabel: UILabel!
    
    var dealsTVC = VendorDetailTVC()
    
    var selectedVenue: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if already checkedIn ...  checkInButton.enabled = false
//        toggleCheckInButton()
        
        // make checkIn button greyed out
        checkInButton.enabled = false
        
        // add plus button
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("pushCreateDealVC"))
        self.navigationItem.rightBarButtonItem = addButton
        
        // set bgimage here as well b/c transparency caused animation issues
        let bgImageView = UIImageView(frame: CGRectMake(0, -65, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        let bgImage = UIImage(named: "bgGradient")
        bgImageView.image = bgImage
        view.insertSubview(bgImageView, atIndex: 0)
        
        // set labels for selected venue
        selectedVenue = ChimeData.mainData().selectedVenue
        
        venueNameLabel.text = selectedVenue["venueName"] as? String
        venueNeighborhoodLabel.text = selectedVenue["venueNeighborhood"] as? String
        venuePhoneLabel.text = selectedVenue["venuePhone"] as? String
        
        // set the title in the nav controller
        self.title = selectedVenue["venueName"] as? String
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 22)!, NSForegroundColorAttributeName: UIColor.clearColor()]   // change to whiteColor if you want to see the venue title up there
        
        // set tableview delegate and data source
        dealsTV.delegate = dealsTVC
        dealsTV.dataSource = dealsTVC
        
        // pass selected venue and deals to tvc
        dealsTVC.selectedVenue = selectedVenue
        if let deals = selectedVenue["venueDeals"] as? [[String:AnyObject]] {
            dealsTVC.venueDeals = deals
            if deals.count > 0 {
                instructionLabel.text = "click on a deal to toggle its availability"
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
    
    func pushCreateDealVC() {
        
        // plus button pressed, present createDealVC to user
        println("Vendor request to create new deal. Pushing to vendorCreateDealVC...")
        let vC = storyboard?.instantiateViewControllerWithIdentifier("vendorCreateDealVC") as VendorCreateDealVC
        self.navigationController?.pushViewController(vC, animated: true)
        
    }
    
//    func toggleCheckInButton() {
//        
//        if ChimeData.mainData().timerIsRunning {
//            
//            checkInButton.enabled = false
//            
//            // change appearance of checkIn button to disabled
//            checkInButton.setTitle("Checked In, Enjoy!", forState: UIControlState.Disabled)
//            
//            // neither of these is working...
//            checkInButton.setNeedsDisplay()
//            view.setNeedsDisplay()
//            
//        } else {
//            
//            checkInButton.enabled = true
//            checkInButton.setNeedsDisplay()
//            
//        }
//        
//        
//        
//    }
    
    /////////
    /////////   TIMER
    /////////
    
//    var timer = NSTimer()
//    var startTime = NSTimeInterval()
//    
//    var dealTime = NSTimeInterval()
//    
//    var geoPoint: PFGeoPoint?
//    var location: CLLocation?
    
    
//    @IBAction func checkIn(sender: AnyObject) {
//        
//        // start timer
//        ChimeData.mainData().timerIsRunning = true
//        
//        let aSelector: Selector = "updateTime"
//        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
//        
//        // check singleton for startTime, if nil, set it here
//        if ChimeData.mainData().startTime > 0 {
//            startTime = ChimeData.mainData().startTime
//        } else {
//            startTime = NSDate.timeIntervalSinceReferenceDate()
//        }
//        
//        // NEED TO ADD THIS BACK ONCE DEALS LOAD
//        //        let venueDeals = selectedVenue["deals"] as [String:String]
//        //
//        //        for (time, deal) in venueDeals {
//        //
//        //            // convert time from hours (string) to seconds (double) and set notifications
//        //            let dealThreshold: NSTimeInterval = ((time as NSString).doubleValue * 10) // change this to * 60 * 60 for production
//        //
//        //            println("Deal time (sec): \(dealThreshold) for deal: '\(deal)'")
//        //
//        //            let fireDate = NSDate(timeInterval: dealThreshold, sinceDate: NSDate())
//        //
//        //            setLocalNotification(fireDate, andAlert: deal)
//        //
//        //
//        //        }
//        
//        
//    }
    
    
    
//    func updateTime() {
//        
//        var currentTime = NSDate.timeIntervalSinceReferenceDate()
//        
//        // find the difference between current time and start time.
//        var elapsedTime: NSTimeInterval = currentTime - startTime
//        
//        // calculate the hours in elapsed time.
//        let hours = UInt8(elapsedTime / 60 / 60)
//        
//        // calculate the minutes in elapsed time.
//        let minutes = UInt8(elapsedTime / 60.0)
//        elapsedTime -= (NSTimeInterval(minutes) * 60)
//        
//        
//        var userLocation = GlobalVariableSharedInstance.currentLocation() as CLLocation
//        
//        var userLatitude = userLocation.coordinate.latitude
//        var userLongitude = userLocation.coordinate.longitude
//        
//        let geoPoint = PFGeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) as PFGeoPoint
//        
//        if let venueLocation = self.location as CLLocation? {
//            
//            var venueLatitude = venueLocation.coordinate.latitude
//            var venueLongitude = userLocation.coordinate.longitude
//            
//            if (userLatitude == venueLatitude) && (userLongitude == venueLongitude){
//                var currentTime = NSDate.timeIntervalSinceReferenceDate()
//                
//                // find the difference between current time and start time.
//                var elapsedTime: NSTimeInterval = currentTime - startTime
//                
//                // calculate the hours in elapsed time.
//                let hours = UInt8(elapsedTime / 60 / 60)
//                
//                // calculate the minutes in elapsed time.
//                let minutes = UInt8(elapsedTime / 60.0)
//                elapsedTime -= (NSTimeInterval(minutes) * 60)
//                
//                // calculate the seconds in elapsed time.
//                let seconds = UInt8(elapsedTime)
//                elapsedTime -= NSTimeInterval(seconds)
//                
//                // add the leading zero for hours, minutes, and seconds and store them as string constants
//                //        let strHours = hours > 9 ? String(hours):"0" + String(hours)
//                let strHours = String(hours)
//                let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
//                let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
//                
//                // concatenate hours, minutes, and seconds as assign it to the UILabel
//                timerLabel.text = "\(strHours):\(strMinutes):\(strSeconds)"
//                
//            }
//            
//        }
//        
//    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        // save startTime to Singleton for when user navigates away from detailVC
//        if startTime > 0 {
//            ChimeData.mainData().startTime = startTime
//            ChimeData.mainData().timeLabel = timerLabel.text!
//        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // retrieve startTime from Singleton if it's saved
//        if ChimeData.mainData().startTime > 0 {
//            timerLabel.text = ChimeData.mainData().timeLabel    // works but causes time to jump the difference
//            checkIn(self)
//        }
        
    }
    
}

class VendorDetailTVC: UITableViewController {
    
    var selectedVenue: PFObject!
    var venueDeals: [[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // update selectedVenue and venueDeals
//        selectedVenue = ChimeData.mainData().selectedVenue
//        
//        if let deals = selectedVenue["venueDeals"] as? [[String:AnyObject]] {
//            venueDeals = deals
//        }
//        
//        tableView.reloadData()
        
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
            println(deal)
            
            let dealName = deal["rewardDescription"] as String
            let dealTime = deal["timeThreshold"] as String
//            let dealTime: String = String(format: "%f", dT)

            
            cell.tagTimeLabel.text = "\(dealTime) hr"
            cell.dealLabel.text = "\(dealName)"
            
        }
        
        return cell
    }
    
    /*
    // allow owner to delete deals from venue TODO: NOT WORKING
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            println("User requests to delete deal from venue...")
            
//            ChimeData.mainData().venues.removeObjectAtIndex(indexPath.row)
            
            let query = PFQuery(className: "Venues")
            
            query.getObjectInBackgroundWithId(selectedVenue.objectId, block: { (venue, error) -> Void in
                //        retrieve Parse venue object so we can add the deals to any existing deals
                if error == nil {
                    
                    var currentVenue: PFObject = venue
                    
                    if var deals = currentVenue["venueDeals"] as? [[String:AnyObject]] {
                        
                    }
                    
                    currentVenue.saveInBackgroundWithBlock({ (success, error) -> Void in
                        
                        if success {

                        } else {
                            println("Error deleting deal from Parse: \(error)")
                        }
                        
                    })
                    
                    
                } else {
                    println("Error loading selected venue from Parse while deleting: \(error)")
                }
                
            })
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    } 
    */
    
}
