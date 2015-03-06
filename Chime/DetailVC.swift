//
//  DetailVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/3/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var dealsTV: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueNeighborhoodLabel: UILabel!
    
    var dealsTVC = DetailTVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set bgimage here as well b/c transparency caused animation issues
        let bgImageView = UIImageView(frame: CGRectMake(0, -65, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        let bgImage = UIImage(named: "bgGradient")
        bgImageView.image = bgImage
        view.insertSubview(bgImageView, atIndex: 0)

        // set tableview delegate and data source
        dealsTV.delegate = dealsTVC
        dealsTV.dataSource = dealsTVC
        dealsTV.reloadData()
        // hide toolbar
        navigationController?.toolbarHidden = true
        

        // remove drink images from navbar (optional)
//        for image in navImageViews {
//            image.removeFromSuperview()
//        }

    }

    /////////
    /////////   TIMER
    /////////
    
    var timer = NSTimer()
    var startTime = NSTimeInterval()

    
    @IBAction func checkIn(sender: AnyObject) {
        
        // start timer
        let aSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        
        // check singleton for startTime, if nil, set it here
        if ChimeData.mainData().startTime > 0 {
            startTime = ChimeData.mainData().startTime
        } else {
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
        
        // TODO: make Check In btn change to "Leave Venue" btn
        // - DONE - make time continue when you leave detailVC
            // - fix how the time label jumps in the ViewWillAppear method
        // - set up notifications
        // - make the time trigger the availability of the deals
        // - idea: 3D cube in venue name space that the user can mess with. when deal is claimed, it falls away revealing the price (an image of a shot glass, "25% off!", etc...
    }
    
    func updateTime() {
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
    
    override func viewWillDisappear(animated: Bool) {

        // save startTime to Singleton for when user navigates away from detailVC
        if startTime > 0 {
            ChimeData.mainData().startTime = startTime
            ChimeData.mainData().timeLabel = timerLabel.text!
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // retrieve startTime from Singleton if it's saved
        if ChimeData.mainData().startTime > 0 {
            timerLabel.text = ChimeData.mainData().timeLabel    // works but causes time to jump the difference
            checkIn(self)
        }
        
    }

}

class DetailTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /////////
    /////////   CONFIGURE TABLEVIEW
    /////////
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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

        // DOESN'T WORK
        // set tag for cell 'claim' button
        cell.claimButton.tag = indexPath.row
        let bSelector: Selector = "dealClaimed"
        cell.claimButton.addTarget(self, action: bSelector, forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    // DOESN'T WORK
    func dealClaimed(sender: DoubleCircleButton) {
        println("deal claimed \(sender.tag)")
        println("here's the issue...")
        
    }
    
}

