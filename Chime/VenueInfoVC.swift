//
//  VenueInfoVC.swift
//  Chime
//
//  Created by William McDuff on 2015-03-10.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit




class VenueInfoVC: UIViewController, sendGeoPointProtocol {

    
    @IBOutlet weak var barNameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
     @IBOutlet weak var neighborhoodField: UITextField!
     @IBOutlet weak var phoneNumberField: UITextField!
    
    
    @IBAction func backToLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveVenueInfo(sender: AnyObject) {
        
        
        var fieldValues: [String] = [barNameField.text, addressField.text, neighborhoodField.text, phoneNumberField.text]
        
        if find(fieldValues, "") != nil {
            
            //all fields are not filled in
            var alertViewController = UIAlertController(title: "Submission Error", message: "Please complete all fields", preferredStyle: UIAlertControllerStyle.Alert)
            
            var defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertViewController.addAction(defaultAction)
            
            presentViewController(alertViewController, animated: true, completion: nil)
        }
            
            
            
        else {
            var address = addressField.text
            
            GlobalVariableSharedInstance.delegate = self
            
            GlobalVariableSharedInstance.addressToLocation(address, completion: { (geoPoint) -> Void in
                
                if let geoPoint = geoPoint {
                    
                    
                    var list:PFObject = PFObject(className: "Venues")
                    list["name"] = self.barNameField.text
                    list["venueAddress"] = self.addressField.text
                    list ["neighborhood"] = self.neighborhoodField.text
                    list["phone"] = self.phoneNumberField.text
                    list["location"] = geoPoint
                    
                    var latitude: CLLocationDegrees = geoPoint.latitude
                    var longitude: CLLocationDegrees = geoPoint.longitude
                    
                    
                    
                    var location = CLLocation.init(latitude: latitude, longitude: longitude)
                    
                    
                    // list["location"] = location
                    
                    if let user = PFUser.currentUser() as PFUser? {
                        list["owner"] = user
                        
                    }
                    
                    
                    
                    
                    var vc = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as LoginVC
                    
                    
                    list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                        
              //       UIApplication.sharedApplication().keyWindow?.rootViewController = vc
                        
            
                      self.presentViewController(vc, animated: true, completion: nil)
                        
                        
                    })
                }
                    
                    
                else {
                    var alertViewController = UIAlertController(title: "Submission Error", message: "The address is not valid", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    var defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alertViewController.addAction(defaultAction)
                    
                    self.presentViewController(alertViewController, animated: true, completion: nil)
                }
                
            })
            
            
            
            
        }
    }
    

     func didReceiveGeoPoint(location: PFGeoPoint) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
