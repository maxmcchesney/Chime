//
//  ChimeData.swift
//  Chime
//
//  Created by Michael McChesney on 3/4/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

let _mainData: ChimeData = ChimeData()

import UIKit

class ChimeData: NSObject {
    // Singleton model
    
    var startTime = NSTimeInterval()
    var startDate: NSDate?
    var timeLabel = ""
    var timerIsRunning: Bool = false 
    
    var selectedVenue: PFObject?
    var checkedInVenue: PFObject?
    
    
    var venues: NSMutableArray = []  // placeholder info
    
    var activatedDeals: [[String:AnyObject]] = []

    /////////
    /////////   refresh the venues list in singleton
    /////////
    
    func refreshSelectedVenueFromParse(completion: () -> ()) {
        
        if selectedVenue == nil { return }
        
        let query = PFQuery(className: "Venues")
        
        query.getObjectInBackgroundWithId(selectedVenue?.objectId, block: { (venue, error) -> Void in
            
            if error == nil {
                // selectedVenue successfully loaded from Parse, update it.
                
                self.selectedVenue = venue
                
            } else {
                println("Error refreshing selectedVenue from Parse. Error: \(error)")
            }
            
            completion()
            
        })
        
    }

    /////////
    /////////   refresh the venues list in singleton
    /////////
    
    
    func refreshVenuesFromParse(sortByDateCreated: Bool?) {
        
        if PFUser.currentUser() == nil {
            return
        }
        
        var query = PFQuery(className:"Venues")
        
        if sortByDateCreated == true {
            query.orderByAscending("createdAt")
        }
        
        /////////
        /////////   CHECK IF USER IS OWNER, IF SO HIDE OTHER VENUES
        /////////
        
        //         check if user is owner
        if let isVenueOwner: Bool = PFUser.currentUser()["isOwner"] as? Bool {
            
            if isVenueOwner {
                // user is an owner, load only his venues
                let ownerVenue = PFUser.currentUser()["venueName"] as! String
                query.whereKey("venueOwner", equalTo: PFUser.currentUser().username)
                
            }
        }
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                println(objects)
                
                self.venues = []
                
                for object in objects {
                    
                    let venue = object as! PFObject
                    self.venues.addObject(venue)
                    
                }
                
            } else {
                println(error)
            }
            
        }
        
    }

    
    
    
    
    ////////////
    
    
    class func mainData() -> ChimeData {
        
        return _mainData
        
    }
   
}
