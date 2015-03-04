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
        
        // set bgimage b/c transparency caused animation issues
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
    
    @IBAction func checkIn(sender: AnyObject) {
        
        // start timer
        let aSelector: Selector = "updateTime"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        
        // TODO: make Check In btn change to "Leave Venue" btn
    }
    
    var startTime = NSTimeInterval()
    
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
        cell.backgroundColor = cellColors[indexPath.row % 2]    // change to % 3 for tri-coloring
        cell.tagView.backgroundColor = cellColors[indexPath.row % 2].colorWithAlphaComponent(0.9)
        
        
        return cell
    }
    
}

