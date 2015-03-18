//
//  VenueTVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit



class VenueTVC: UITableViewController, userLocationProtocol, CLLocationManagerDelegate, segmentedControllerDidChangeProtocol {
    
    
    var parseVenues: NSMutableArray = []
    
//    var checkins = []
    
    
    var isOwner: Bool = false
    var ownerVenue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        tableView.backgroundColor = UIColor.clearColor()
        
        // load the venues from Parse
        // self.loadVenuesFromParse()

        var nc = self.navigationController as RootNavigationController
        nc.delegate2 = self
        
        if userLocation != nil { loadVenuesFromParse(false) }
        
        println("PFUSER: \(PFUser.currentUser())")
        
        // STUFF TO USE
        
      GlobalVariableSharedInstance.delegate = self
        GlobalVariableSharedInstance.initLocationManager()
        // calls finddistance indefinitly
        GlobalVariableSharedInstance.findLocation()

    }

    
    override func viewWillAppear(animated: Bool) {
        
        // check if user is logged in already
        checkIfLoggedIn()
        
        

        if userLocation != nil { loadVenuesFromParse(false) }
        
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
            query.orderByAscending("createdAt")
        }
        
        else {
            // this only allows users to see deals near them.  what's the distance threshold?
            query.whereKey("location", nearGeoPoint: PFGeoPoint(location: userLocation))

        }
        

        /////////
        /////////   CHECK IF USER IS OWNER, IF SO HIDE OTHER VENUES
        /////////
        
//         check if user is owner
        if let isVenueOwner: Bool = PFUser.currentUser()["isOwner"] as? Bool {
            
            if isVenueOwner {
                // user is an owner, load only his venues
                let ownerVenue = PFUser.currentUser()["venueName"] as String
                println("User is an owner of: \(ownerVenue)")
                query.whereKey("venueOwner", equalTo: PFUser.currentUser().username)
                
                // DOESNT WORK FOR SOME REASON
                self.title = "Your Venues"
                navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 22)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
                
                // add plus button
                let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: nil)
                self.navigationItem.rightBarButtonItem = addButton
                
                // TODO: user is owner, either hide the toolbar or change it to "my venues" and "all venues"
                navigationController?.toolbarHidden = true
                isOwner = true
            }
        }
        
        if isOwner {
            
            // TODO: user is owner, either hide the toolbar or change it to "my venues" and "all venues"
            //            navigationController?.toolbarHidden = true
            
        } else {
            
            // unhide the toolbar
            navigationController?.toolbarHidden = false
            self.navigationItem.rightBarButtonItem = nil
            self.title = ""
            //        // add the images back to navbar
            for image in navImageViews {
                navigationController?.navigationBar.addSubview(image)
            }
            
            //            navigationController?.navigationItem.setRightBarButtonItem(nil, animated: false)
            
        }
        
//        if isOwner {
//            query.whereKey("venueOwner", equalTo: PFUser.currentUser().username)
//        }
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                println(objects)
                
                self.parseVenues = []
                
                for object in objects {
                    
                    let venue = object as PFObject
                    self.parseVenues.addObject(venue)
                    
                }
                
                self.tableView.reloadData()
//               self.sortVenuesByDistanceFromUser()
                
            }

            println(error)
            
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
        
        // after using the distance key to sort the array of dictionary, add all the usernames (sorted by distance) to the array of female users
        for dictionary in sortedArray
        {
            
            var venue = dictionary["venueName"] as PFObject
            
            var distance = dictionary["distance"] as NSNumber
            
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
                var firstDictionary = array.objectAtIndex(i) as NSDictionary
                var secondDictionary = array.objectAtIndex(j) as NSDictionary
                
                // if the value for key ditstance is smaller in the second than in the first inverse
                if (Int(secondDictionary["distance"] as NSNumber) < Int(firstDictionary["distance"] as NSNumber))
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
                self.presentViewController(lVC, animated: true, completion: nil)
                println("No currentUser found, presenting log in...")
            }
        }
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        // log out user
        println("User logging out...")
        PFUser.logOut()
        checkIfLoggedIn()
        isOwner = false
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("venueCell", forIndexPath: indexPath) as VenueCell

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
            
            if let venueName  = venue["venueName"] as String? {
                cell.venueName.text = venueName
                
                // if user is owner, change label to reflect that (optional)
//                if isOwner {
//                    cell.venueName.text = venueName + " (owner)"
//                }
                
            }
            if let venueNeighborhood: String = venue["venueNeighborhood"] as String? {
                cell.venueNeighborhood.text = venueNeighborhood
            }
            
            // THIS NEEDS FIXING ONCE WE HAVE A WAY TO CREATE DEALS
//            if let deals: [String:String] = venue["deals"] as? [String:String] {
//                cell.tagNumberOfDealsLabel.text = "\(deals.count)"  // TODO: placeholder $ amount right now
//            }
            
            if let userLocation = userLocation {
                
                let venueGeo = venue["location"] as PFGeoPoint
                let venueLocation = CLLocation(latitude: venueGeo.latitude, longitude: venueGeo.longitude)
                let distance = Float(userLocation.distanceFromLocation(venueLocation)) * 0.000621371
                
                // round distance
                let roundedDistance = round(distance * 100) / 100
                
                cell.venueDistance.text = "\(roundedDistance)mi"
                
            }
            
//            Float(distance) * 0.000621371
            
//           if let distance = venue["distance"] as Float? {
//            }
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
        
        println("User has selected a venue, pushing detail view...")
        
        let venue: AnyObject = self.parseVenues[indexPath.row]
        
        let venueGeo = venue["location"] as PFGeoPoint
        let venueLocation = CLLocation(latitude: venueGeo.latitude, longitude: venueGeo.longitude)
        
        let dVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailVC") as DetailVC

        // set selected venue
        ChimeData.mainData().selectedVenue = parseVenues[indexPath.row] as? PFObject
        
        dVC.geoPoint = venueGeo
        dVC.location = venueLocation

        self.navigationController?.pushViewController(dVC, animated: true)
        
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

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

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
