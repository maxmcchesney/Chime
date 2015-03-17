//
//  VenueTVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/2/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit



class VenueTVC: UITableViewController, userLocationProtocol, CLLocationManagerDelegate, segmentedControllerDidChangeProtocol {
    
      var venues = [[:]]
    

    var parseVenues: NSMutableArray = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var nc = self.navigationController as RootNavigationController
        nc.delegate2 = self
        
        
        println("PFUSER: \(PFUser.currentUser())")
        
        // STUFF TO USE
        
      GlobalVariableSharedInstance.delegate = self
        GlobalVariableSharedInstance.initLocationManager()
        // calls finddistance indefinitly
        GlobalVariableSharedInstance.findLocation()
        
        
  //      self.loadVenuesFromParse()
        tableView.backgroundColor = UIColor.clearColor()


    }

    
    override func viewWillAppear(animated: Bool) {
        
        venues = [  // placeholder info
            
            [
                "venueName":"The Family Dog",
                "venueAddress":"1402 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Hand In Hand",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs"
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Neighbors",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR"
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Park Tavern",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                    "4 hr":"10% off bar tab"
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA 30306",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ],
            [
                "venueName":"Manuel's",
                "venueAddress":"752 North Highland Avenue Northeast, Atlanta, GA",
                "deals":[
                    "1 hr":"25% off a PBR",
                    "2 hr":"2 free Fireballs",
                    "3 hr":"10% off bar tab",
                ],
                "neighborhood":"va highlands",
                "phone":"(404) 249-0180"
            ]
        ]
        
        
         /*

        var firstVenue = venues[0] as [String: AnyObject]
        
       
        
        println(firstVenue)
        
        
        println(firstVenue["venueAddress"])
        if let address = firstVenue["venueAddress"] as String? {

            if let location: PFGeoPoint? = GlobalVariableSharedInstance.addressToLocation(address) as PFGeoPoint? {
                println(location)
            }
        }
        
        */
        

        
        // unhide the toolbar
        navigationController?.toolbarHidden = false
//        // add the images back to navbar
        for image in navImageViews {
            navigationController?.navigationBar.addSubview(image)
        }
        
        // check if user is logged in already
        checkIfLoggedIn()
        
        /////////
        /////////   PLACEHOLDER INFO
        /////////
        
    }
    
    var userLocation: CLLocation?
    
    func loadVenuesFromParse(sortByDateCreated: Bool?) {
        
        println(userLocation)
        
        
    
        var query = PFQuery(className:"Venues")

        
        if sortByDateCreated == true {
            query.orderByAscending("createdAt")
        }
        
        else {
            query.whereKey("location", nearGeoPoint: PFGeoPoint(location: userLocation))

        }
        
        println(query)
        
        
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
                
                
                
                // After loading the lists where we are the owner, load the list that other users has shared with user
            
            
            }
            println(error)
            

        }
    }
    
    
    
    func sortVenuesByDistanceFromUser() {
        
        var arrayOfVenuesDictionaries = [] as [AnyObject]

        
        for venue in self.parseVenues {
            var distance = NSNumber(int: -1)
            let location:PFGeoPoint? = venue["location"] as? PFGeoPoint
            if location != nil
            {
                distance = GlobalVariableSharedInstance.findDistance( location ) as NSNumber

            }
            var dictionary = NSDictionary(objects: [venue, distance], forKeys: ["venue", "distance"])
            
            arrayOfVenuesDictionaries.append(dictionary)

        }
        
        var sortedArray = self.sortArray(NSMutableArray(array: arrayOfVenuesDictionaries))
        
        // Reinitiate our array of female users (with the size only of the not chosen female users)
        self.parseVenues = NSMutableArray(capacity: sortedArray.count)
        
        // after using the distance key to sort the array of dictionary, add all the usernames (sorted by distance) to the array of female users
        for dictionary in sortedArray
        {
            
            var venue = dictionary["venue"] as PFObject
            
            var distance = dictionary["distance"] as NSNumber
            
            
      
            venue["distance"] = Float(distance) * 0.000621371
            
            // make the last object the nearest user
            self.parseVenues.addObject(venue)
        }

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

    
    func checkIfLoggedIn() {
        // check if user is already logged in
        if PFUser.currentUser() != nil {
            // user is already logged in
            println("User is already logged in, presenting venues...")
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
    }


    
    /////////
    /////////   CONFIGURE TABLEVIEW
    /////////

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return self.parseVenues.count
        
        
       // return venues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        
            /*
        let venue = venues[indexPath.row]
        let venueName: String = venue["venueName"] as String
        let venueNeighborhood: String = venue["neighborhood"] as String
        if let deals: [String:String] = venue["deals"] as? [String:String] {
            cell.tagLabel.text = "$\(deals.count + 4)"  // TODO: placeholder $ amount right now
        }
        cell.venueName.text = venueName
        cell.venueNeighborhood.text = venueNeighborhood
 */
        
        // set cell labels
        
        if let venue: AnyObject = parseVenues[indexPath.row]  as AnyObject? {
            
            if let venueName  = venue["name"] as String? {
                cell.venueName.text = venueName
            }
            if let venueNeighborhood: String = venue["neighborhood"] as String? {
                cell.venueNeighborhood.text = venueNeighborhood
            }
            
            if let deals: [String:String] = venue["deals"] as? [String:String] {
                cell.tagLabel.text = "$\(deals.count + 4)"  // TODO: placeholder $ amount right now
            }
            
            if let userLocation = userLocation {
                
                
                let venueGeo = venue["location"] as PFGeoPoint
                let venueLocation = CLLocation(latitude: venueGeo.latitude, longitude: venueGeo.longitude)
                let distance = Float(userLocation.distanceFromLocation(venueLocation)) * 0.000621371
                
                cell.venueDistance.text = "\(distance)mi"
                
            }
            
//            Float(distance) * 0.000621371

            
//           if let distance = venue["distance"] as Float? {
//            }
        }
   

        
        
        return cell
        
    }
    
    
    /////////
    /////////   PUSH DETAIL VIEW CONTROLLER WHEN CELL IS SELECTED
    /////////
    
    func didReceiveUserLocation(location: CLLocation) {
        
        userLocation = location
        
        self.loadVenuesFromParse(false)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("User has selected a venue, pushing detail view...")
        
        let venue: AnyObject = self.parseVenues[indexPath.row]
        

        let venueGeo = venue["location"] as PFGeoPoint
        let venueLocation = CLLocation(latitude: venueGeo.latitude, longitude: venueGeo.longitude)
        
        
        let dVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailVC") as DetailVC
        
        dVC.geoPoint = venueGeo
        dVC.location = venueLocation
//        dVC.navigationController?.toolbarHidden = true

    
        self.navigationController?.pushViewController(dVC, animated: true)
        
    }
    
    
    
     func segmentedControllerDidChange(value: Int) {
        
        
        if value == 0 {
            
            
            self.loadVenuesFromParse(false)
            
        }
        
        
        if value == 1 {
            
            self.loadVenuesFromParse(true)
            
            
            
        }

        //
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
