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
        // TODO: change the phone label to show how many users are in a venue
//        venuePhoneLabel.text = selectedVenue["venuePhone"] as? String
        
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
                instructionLabel.text = "Click on a deal to toggle whether users see it as available."
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
                self.instructionLabel.text = "Click on a deal to toggle whether users see it as available."
            }
            
            self.dealsTV.reloadData()
            
        }
        
    }
    
    func pushCreateDealVC() {
        
        // plus button pressed, present createDealVC to user
        println("Vendor request to create new deal. Pushing to vendorCreateDealVC...")
        let vC = storyboard?.instantiateViewControllerWithIdentifier("vendorCreateDealVC") as! VendorCreateDealVC
        self.navigationController?.pushViewController(vC, animated: true)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
}

class VendorDetailTVC: UITableViewController {
    
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
        return venueDeals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dealCell", forIndexPath: indexPath) as! DealCell
        
        // Configure the cell...
        cell.indicatorArrow.hidden = false
        
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
            
            let status: Bool = deal["active"] as! Bool
            if !status {
                // deal is inactive
                cell.backgroundColor = UIColor.lightGrayColor()
                cell.tagView.backgroundColor = UIColor.grayColor()
                cell.dealLabel.text = "\(dealName) (inactive)"
            }
            
        }
        
        return cell
    }
    
    /////////
    /////////   TOGGLE DEAL AVAILABILITY
    /////////
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // toggle the deals availability when a cell is touched
        println("Owner has selected a deal cell...")
        
        if let deals: NSMutableArray = selectedVenue["venueDeals"] as? NSMutableArray {
            
            var deal = deals[indexPath.row] as! [String:AnyObject]
            
            var status: Bool = deal["active"] as! Bool
            
            if status {
                // deal is active, switch to inactive
                deal["active"] = false
            } else {
                // deal is inactive switch to active
                deal["active"] = true
            }
            
            deals.replaceObjectAtIndex(indexPath.row, withObject: deal)

            selectedVenue.saveInBackground()
            
        }

        tableView.reloadData()
        
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
