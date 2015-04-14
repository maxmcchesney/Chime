//
//  VenueTVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit



class VenueTVC: UITableViewController, userLocationProtocol, CLLocationManagerDelegate, segmentedControllerDidChangeProtocol {
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerLabel: UILabel!
    @IBOutlet weak var bannerButton: DesignableButton!
    @IBOutlet weak var bannerDownArrow: CustomDownArrow!
    
    var parseVenues: NSMutableArray = []
    
    var isOwner: Bool = false
    var ownerVenue: String?
    
    var bannerFrame: CGRect?
    
    /////////
    /////////   CHECK IF LOGGED IN
    /////////
    
    func checkIfLoggedIn() {
        // check if user is already logged in
        if PFUser.currentUser() != nil {
            // user is already logged in
            println("User is already logged in...")
            
        } else {
            // no user found, present loginVC
            if let lVC = storyboard?.instantiateViewControllerWithIdentifier("loginVC") as? LoginVC {
                self.presentViewController(lVC, animated: false, completion: nil)
                println("No currentUser found, presenting log in...")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check if user is logged in already
        checkIfLoggedIn()

        tableView.backgroundColor = UIColor.clearColor()

        var nc = self.navigationController as! RootNavigationController
        nc.delegate2 = self
        
        if userLocation != nil { loadVenuesFromParse(false) }
        
        println("PFUSER: \(PFUser.currentUser())")
        
        // STUFF TO USE
        
      GlobalVariableSharedInstance.delegate = self
        GlobalVariableSharedInstance.initLocationManager()
        // calls finddistance indefinitly
        GlobalVariableSharedInstance.findLocation()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !isOwner {
            
            // unhide the toolbar
            navigationController?.toolbarHidden = false
            self.navigationItem.rightBarButtonItem = nil
            self.title = ""

        // add the images back to navbar
            
            for image in navImageViews {
                
                self.navigationController?.navigationBar.addSubview(image)
                
                image.hidden = false
                
                // animate the buttons from the bottom
                var scale1 = CGAffineTransformMakeScale(0.5, 0.5)
                var translate1 = CGAffineTransformMakeTranslation(200, 0)
                image.transform = CGAffineTransformConcat(scale1, translate1)
                
                animationWithDuration(1) {
                    
                    var scale = CGAffineTransformMakeScale(1, 1)
                    var translate = CGAffineTransformMakeTranslation(0, 0)
                    image.transform = CGAffineTransformConcat(scale, translate)

                }
                
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // hide images for animation
        for image in navImageViews {
            image.hidden = true
            image.removeFromSuperview()
        }
        
        // set the badge icon to 0
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        if let venue = ChimeData.mainData().checkedInVenue as PFObject? {
            
            // SHOW BANNER VIEW
            let vName: String = ChimeData.mainData().checkedInVenue?["venueName"] as! String
            bannerLabel.text = "You're checked in at \(vName)!"
            bannerView.hidden = false
            bannerView.frame.size.height = 44
            tableView.tableHeaderView = bannerView
            
        } else {
            
            // HIDE BANNER VIEW
            bannerView.hidden = true
            bannerView.frame.size.height = 0
            tableView.tableHeaderView = bannerView
            
        }

        if userLocation != nil { loadVenuesFromParse(false) }
        
    }
    
    func addNewVenue() {
        // plus button pressed, send user to NewVenueTVC
        let vC = storyboard?.instantiateViewControllerWithIdentifier("newVenueVC") as! NewVenueVC
        navigationController?.pushViewController(vC, animated: true)
        
    }
    
    /////////
    /////////   LOAD VENUES FROM PARSE AND SORT ACCORDINGLY
    /////////
    
    var userLocation: CLLocation?
    
    func loadVenuesFromParse(sortByDateCreated: Bool?) {
        
//        println(userLocation)
        
        if PFUser.currentUser() == nil {
            return
        }
        
        var query = PFQuery(className:"Venues")

        if sortByDateCreated == true {
            query.orderByDescending("createdAt")
        }
        
        else {
            // this only allows users to see deals near them.  TODO: Change withinMiles based on something?
            query.whereKey("location", nearGeoPoint: PFGeoPoint(location: userLocation), withinMiles: 50.0)
//            query.whereKey("location", nearGeoPoint: PFGeoPoint(location: userLocation))

        }
        
        /////////
        /////////   CHECK IF USER IS OWNER, IF SO HIDE OTHER VENUES
        /////////
        
//         check if user is owner
        if let isVenueOwner: Bool = PFUser.currentUser()["isOwner"] as? Bool {
            
            if isVenueOwner {
                // user is an owner, load only his venues
                let ownerVenue = PFUser.currentUser()["venueName"] as! String
                println("User is an owner of: \(ownerVenue)")
                query.whereKey("venueOwner", equalTo: PFUser.currentUser().username)
                
                // set the title in the nav controller
                self.title = "Venues"
                navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
                
                // add plus button
                let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addNewVenue"))
                self.navigationItem.rightBarButtonItem = addButton
                
                // TODO: user is owner, either hide the toolbar or change it to "my venues" and "all venues"
                navigationController?.toolbarHidden = true
                isOwner = true
            }
        }
        
        if !isOwner {
            
            // unhide the toolbar
            navigationController?.toolbarHidden = false
            self.navigationItem.rightBarButtonItem = nil
            self.title = ""

        }
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                println(objects)
                
                self.parseVenues = []
                
                for object in objects {
                    
                    let venue = object as! PFObject
                    self.parseVenues.addObject(venue)
                    
                }
                
                self.tableView.reloadData()
                
            } else {
                println(error)
            }
            
        }

    }
    
    /////////
    /////////   SORT VENUES BY DISTANCE FROM USER
    /////////
    
    func sortVenuesByDistanceFromUser() {
        
        var arrayOfVenuesDictionaries = [] as [AnyObject]

        
        for venue in self.parseVenues {
            var distance = NSNumber(int: -1)
            let location:PFGeoPoint? = venue["location"] as? PFGeoPoint
            if location != nil
            {
                distance = GlobalVariableSharedInstance.findDistance( location ) as NSNumber

            }
            var dictionary = NSDictionary(objects: [venue, distance], forKeys: ["venueName", "distance"])
            
            arrayOfVenuesDictionaries.append(dictionary)

        }
        
        var sortedArray = self.sortArray(NSMutableArray(array: arrayOfVenuesDictionaries))
        
        // Reinitiate our array of venues
        self.parseVenues = NSMutableArray(capacity: sortedArray.count)
        
        // after using the distance key to sort the array of dictionary, add all the usernames (sorted by distance)
        for dictionary in sortedArray
        {
            
            var venue = dictionary["venueName"] as! PFObject
            
            var distance = dictionary["distance"] as! NSNumber
            
            venue["distance"] = Float(distance) * 0.000621371
            
            // make the last object the nearest user
            self.parseVenues.addObject(venue)
        }

        // save the data to the singleton and reload the tableview
        ChimeData.mainData().venues = self.parseVenues
        self.tableView.reloadData()
    }
    
    
    func sortArray(array:NSMutableArray) -> NSArray
    {
        var n = array.count
        
        // for first element to beforelast, for second element to last (ALWAYS COMPARE WITH THE NEXT ELEMENT, then exchange if second bigger)
        for var i = 0; i < ( n - 1 ); i++
        {
            for var j = i+1; j < n ; j++
            {
                // first element and second element
                var firstDictionary = array.objectAtIndex(i) as! NSDictionary
                var secondDictionary = array.objectAtIndex(j) as! NSDictionary
                
                // if the value for key ditstance is smaller in the second than in the first inverse
                if (Int(secondDictionary["distance"] as! NSNumber) < Int(firstDictionary["distance"] as! NSNumber))
                {
                    // first element (NOT USEFUL)
                    var temp = firstDictionary
                    
                    // swap two elements
                    array.replaceObjectAtIndex(i, withObject: secondDictionary)
                    array.replaceObjectAtIndex(j, withObject: firstDictionary)
                }
            }
        }
        
        return array
    }

    @IBAction func logOut(sender: UIBarButtonItem) {
        // log out user
        println("User logging out...")
        PFUser.logOut()
        checkIfLoggedIn()
        
        // reset everything
        isOwner = false
        ChimeData.mainData().checkedInVenue = nil
        ChimeData.mainData().selectedVenue = nil
        ChimeData.mainData().timerIsRunning = false
        ChimeData.mainData().startTime = 0
        ChimeData.mainData().activatedDeals = []
        ChimeData.mainData().timeLabel = ""

    }
    
    /////////
    /////////   GO TO CHECKED IN VENUE BUTTON
    /////////

    @IBAction func goToVenue(sender: AnyObject) {
//    user has pressed button to go to checked in venue
        
        ChimeData.mainData().selectedVenue = ChimeData.mainData().checkedInVenue
        if let venue = ChimeData.mainData().checkedInVenue {
            
            let venueGeo = venue["location"] as! PFGeoPoint
            let venueLocation = CLLocation(latitude: venueGeo.latitude, longitude: venueGeo.longitude)
            
            let dVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailVC") as! DetailVC
            
            dVC.geoPoint = venueGeo
            dVC.location = venueLocation
            
            self.navigationController?.pushViewController(dVC, animated: true)
            
        }
    }
    
    /////////
    /////////   CONFIGURE TABLEVIEW
    /////////

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return self.parseVenues.count

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /// 
        
        let cell = tableView.dequeueReusableCellWithIdentifier("venueCell", forIndexPath: indexPath) as! VenueCell

        // Configure the cell...
        
        
        // set up the cell coloring
        let lighterColor: UIColor = UIColor(red:0.71, green:0.87, blue:0.55, alpha:0.5)
        let middleColor: UIColor = UIColor(red:0.56, green:0.78, blue:0.35, alpha:0.5)
        let darkerColor: UIColor = UIColor(red:0.43, green:0.62, blue:0.25, alpha:0.5)
        let cellColors = [middleColor, darkerColor, lighterColor]
        cell.backgroundColor = cellColors[indexPath.row % 2]    // change to % 3 for tri-coloring
        cell.tagView.backgroundColor = cellColors[indexPath.row % 2].colorWithAlphaComponent(0.9)
        
        // set cell labels
        
        if let venue: AnyObject = parseVenues[indexPath.row]  as AnyObject? {
            
            if let venueName  = venue["venueName"] as! String? {
                cell.venueName.text = venueName
                
                
            }
            if let venueNeighborhood: String = venue["venueNeighborhood"] as! String? {
                cell.venueNeighborhood.text = venueNeighborhood
            }
            
            if venue.objectId == ChimeData.mainData().checkedInVenue?.objectId {
                
                println("\(venue) has been checked in to...")
                // venue is the one checked in to, set tag to blue and neighborhood text
                cell.tagView.backgroundColor = blueActivated.colorWithAlphaComponent(0.5)
                cell.venueNeighborhood.text = "Chimed in here!"
//                cell.venueNeighborhood.textColor = blueActivated
//                cell.indicatorArrow.strokeColor = blueActivated
//                cell.indicatorArrow.setNeedsDisplay()
             
            }

//            set the deal count label
            if let deals: [[String:AnyObject]] = venue["venueDeals"] as? [[String:AnyObject]] {
                
                cell.tagNumberOfDealsLabel.text = "\(deals.count)"
                
                var totalValue = 0
                for deal in deals {
                    let value = deal["estimatedValue"] as! Int
                    totalValue += value
                }
                
                cell.tagValueLabel.text = "$\(totalValue)"
                
                if totalValue >= 50 {
                    cell.tagValueLabel.text = "$50+"
                } else {
                    cell.tagValueLabel.text = "$\(totalValue)"
                }
                
            } else {
                // venue has no deals
                cell.tagValueLabel.text = "n/a"
                cell.tagNumberOfDealsLabel.text = "0"
                cell.tagView.backgroundColor = UIColor.lightGrayColor()
            }
            
            if let userLocation = userLocation {
                
                let venueGeo = venue["location"] as! PFGeoPoint
                let venueLocation = CLLocation(latitude: venueGeo.latitude, longitude: venueGeo.longitude)
                let distance = Float(userLocation.distanceFromLocation(venueLocation)) * 0.000621371
                
                // round distance
                let roundedDistance = round(distance * 100) / 100
                
                cell.venueDistance.text = "\(roundedDistance)mi"
                
            }
            
        }
   
        return cell
        
    }
    
    func didReceiveUserLocation(location: CLLocation) {
        
        userLocation = location
        
        self.loadVenuesFromParse(false)
    }
    
    /////////
    /////////   PUSH DETAIL VIEW CONTROLLER WHEN CELL IS SELECTED
    /////////
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let venue: AnyObject = self.parseVenues[indexPath.row]  // should this be AnyObject or PFObject like below?
        
        // set selected venue
        ChimeData.mainData().selectedVenue = parseVenues[indexPath.row] as? PFObject
        
        // if user is an owner, push to vendorDetailVC, otherwise, send user to DetailVC
        if isOwner {
            println("User is an owner, pushing vendor detail view...")
            
            let vDVC = self.storyboard?.instantiateViewControllerWithIdentifier("vendorDetailVC") as! VendorDetailVC
            
            self.navigationController?.pushViewController(vDVC, animated: true)
            
        } else {
            
            println("User has selected a venue, pushing detail view...")
            
            let venueGeo = venue["location"] as! PFGeoPoint
            let venueLocation = CLLocation(latitude: venueGeo.latitude, longitude: venueGeo.longitude)
            
            let dVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailVC") as! DetailVC
            
            dVC.geoPoint = venueGeo
            dVC.location = venueLocation
            
            self.navigationController?.pushViewController(dVC, animated: true)
            
        }

    }
    
    /////////
    /////////   SORT VENUES BASED ON SEGMENT CONTROLLER
    /////////
    
     func segmentedControllerDidChange(value: Int) {
        // sort venues based on distance or creation date
        if value == 0 {
            self.loadVenuesFromParse(false)
        }

        if value == 1 {
            self.loadVenuesFromParse(true)
        }
        // TODO: allow owners to sort b/w all venues and their venues
    }

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
