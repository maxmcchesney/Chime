//
//  NewVenueTVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/20/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class NewVenueVC: UIViewController {

    @IBOutlet weak var venueNameField: UITextField!
    @IBOutlet weak var venueAddressField: UITextField!
    @IBOutlet weak var venuePhoneField: UITextField!
    @IBOutlet weak var venueNeighborhoodField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()    // set tableview background to clear
        
        // load background image w/ gradient.
        let bgImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        
        let bgImage = UIImage(named: "greenBackground")
        bgImageView.image = bgImage
        //        bgImageView.contentMode = UIViewContentMode.ScaleToFill
        view.insertSubview(bgImageView, atIndex: 0)
        
        // set the title in the nav controller
        self.title = "New Venue"
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 24)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    /////////
    /////////   SAVE VENUE
    /////////
    
    @IBAction func checkFields(sender: AnyObject) {
        // email / pw field validation
        var fieldValues: [String] = [venueNameField.text,venueAddressField.text,venuePhoneField.text,venueNeighborhoodField.text]
        if find(fieldValues, "") != nil {
            // all fields are not filled in, present alert
            var alertViewController = UIAlertController(title: "Submission Error", message: "Please fill in all fields.", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)
        } else {
            // all fields are filled in, check if user exists
            self.saveVenue()
        }
    }  // end: field validation
    
    
    func saveVenue() {
        
        var address = self.venueAddressField.text
        
        //        GlobalVariableSharedInstance.delegate = self
        
        GlobalVariableSharedInstance.addressToLocation(address, completion: { (geoPoint) -> Void in
            
            if let geoPoint = geoPoint {
                
                var venueInfo:PFObject = PFObject(className: "Venues")
                venueInfo["venueName"] = self.venueNameField.text
                venueInfo["venueAddress"] = self.venueAddressField.text
                venueInfo["venueNeighborhood"] = self.venueNeighborhoodField.text
                venueInfo["venuePhone"] = self.venuePhoneField.text
                venueInfo["location"] = geoPoint
                venueInfo["venueOwner"] = PFUser.currentUser().email
                
                // list["location"] = location
                
                venueInfo.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                    
                    if error == nil {
                        // venue is successfully saved to parse, dismiss vc
                        println("Venue registration succeeded. Venue created: \(self.venueNameField.text)")
                        
                        makeVibrate()
                        
                        // dismiss vc and push to navigationvc
                        if let nc = self.storyboard?.instantiateViewControllerWithIdentifier("navigationC") as? RootNavigationController {
                            //                        self.dismissViewControllerAnimated(true, completion: nil)   // necessary?
                            self.presentViewController(nc, animated: true, completion: nil)
                        }
                    } else {
                        println(error)
                    }

                })
            }
            
        })
        
    }
    
    // not sure what this does but it conforms us to the protocol..
    func didReceiveGeoPoint(location: PFGeoPoint) {
        println("didReceiveGeoPoint function ran...")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // dismiss keyboard when user touches outside textfields
        view.endEditing(true)
        //        tableView.endEditing(true)
        super.touchesBegan(touches, withEvent: event)   // ?? is this necessary
    }

}
