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

    /////////
    /////////   PLACEHOLDER INFO (if you put too much here, it will index crash. you have to append for more data.)
    /////////
    var venues: NSMutableArray = []  // placeholder info
    
//    DATA MODEL
//        [
//            "venueName":"The Family Dog",
//            "venueAddress":"1402 North Highland Avenue Northeast, Atlanta, GA 30306",
//            "deals":[
//            "1":"ONE FREE PBR",    // the number is the # of hours for the deal threshold as a string
//            "2":"TWO FREE FIREBALL SHOTS",
//            "3":"$10 OFF YOUR FINAL TAB ($25 MINIMUM)",
//            ],
//            "neighborhood":"virginia highlands",
//            "phone":"(404) 249-0180",
//            "accountCreated":"5/12/14"
//        ],


    
    
    
    class func mainData() -> ChimeData {
        
        return _mainData
        
    }
   
}
