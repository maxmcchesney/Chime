//
//  VendorCreateDealVC.swift
//  Chime
//
//  Created by Michael McChesney on 3/18/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class VendorCreateDealVC: UIViewController, CustomSliderDelegate {
    
    @IBOutlet weak var describeRewardField: UITextField!
    @IBOutlet weak var additionalDetailsField: UITextField!
    
    @IBOutlet weak var timeRequiredLabel: UILabel!
    @IBOutlet weak var estimatedValueLabel: UILabel!
    
    @IBOutlet weak var previewCellView: UIView!
    @IBOutlet weak var previewTagView: UIView!
    @IBOutlet weak var previewDealLabel: UILabel!
    @IBOutlet weak var previewTagLabel: UILabel!
    @IBOutlet weak var previewTagValueLabel: UILabel!
    
    @IBOutlet weak var timeSliderValue: CustomSlider!
    @IBOutlet weak var valueCustomSlider: CustomSlider!
    
    var selectedVenue: PFObject!
    var venueName: String!
    var venueID: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // set bgimage here as well b/c transparency caused animation issues
        let bgImageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        let bgImage = UIImage(named: "bgGradient")
        bgImageView.image = bgImage
        view.insertSubview(bgImageView, atIndex: 0)

        // hide the toolbar
        navigationController?.toolbarHidden = true
        
        // add save button
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("saveDeal"))
        self.navigationItem.rightBarButtonItem = saveButton
        
        // set the title and font in the nav controller
        selectedVenue = ChimeData.mainData().selectedVenue
        venueName = selectedVenue["venueName"] as? String
        venueID = selectedVenue.objectId
//        println("SELECTED VENUE: \(selectedVenue), with name: \(venueName)")
//        self.title = venueName
//        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 22)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // set color of preview cell and tag view
        let cellColor = UIColor(red:0.43, green:0.62, blue:0.25, alpha:0.5)
        previewCellView.backgroundColor = cellColor
        previewTagView.backgroundColor = cellColor.colorWithAlphaComponent(0.9)
        
        // set up the custom sliders
        timeSliderValue.delegate = self
        timeSliderValue.sliderType = "time"
        valueCustomSlider.delegate = self
        valueCustomSlider.sliderType = "value"
        
    }
    
    var timeRequired: Double = 0
    var estimatedValue: Int = 0
    func sliderValue(value: Float, forSlider sliderType: String!) {
        
        if sliderType == "time" {
            // slider value changing for time label
        
//            var timeRequired = Int(floor(value * 10)) // use this one for 1-10 incremented by 1
            timeRequired = Double(round((value * 9) * 2)) / 2  // use this one for 1-10 incremented by .5
            if timeRequired >= 1 {
                timeRequiredLabel.text = "Time Required: \(timeRequired) hrs"
            } else {
                timeRequiredLabel.text = "Time Required: \(timeRequired) hr"
            }
            
        }
        
        if sliderType == "value" {
            // slider value changing for value label
            
            estimatedValue = Int(floor(value * 50))
            if estimatedValue < 50 {
                estimatedValueLabel.text = "Estimated Value: $\(estimatedValue)"
            } else {
                estimatedValueLabel.text = "Estimated Value: $\(estimatedValue)+"
            }

        }
        
    }
    
    func saveSliderValue() {
        // set the preview cell labels to the slider values (add the hrs and + if required)
        previewTagLabel.text = "\(timeRequired) hr"
        previewTagValueLabel.text = "$\(estimatedValue)"
    }
    
    func saveDeal() {
        // save the new deal to the vendor's account
        println("Vendor requests to save the new deal...")
        
        // check for reward description and time required
        if describeRewardField.text == "" || timeRequired == 0 {
            // all fields are not filled in, present alert
            var alertViewController = UIAlertController(title: "Submission Error", message: "Reward description and time required must be set to create a new deal!", preferredStyle: UIAlertControllerStyle.Alert)
            var defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertViewController.addAction(defaultAction)
            presentViewController(alertViewController, animated: true, completion: nil)
        } else {
            // all validations are good, proceed to save deal
            
            let newDeal = [
                    
                    "timeThreshold":(timeRequired as NSNumber).stringValue,
                    "rewardDescription":describeRewardField.text,
                    "additionalDetails":additionalDetailsField.text,
                    "estimatedValue":estimatedValue,
                    "active":true,
                    "timeCreated":NSDate()
                    
                ]
            
            let query = PFQuery(className: "Venues")
            
            query.getObjectInBackgroundWithId(venueID, block: { (venue, error) -> Void in
                //        retrieve Parse venue object so we can add the deals to any existing deals
                if error == nil {
                    println(venue)
                    
                    var currentVenue: PFObject = venue

                    if var deals = currentVenue["venueDeals"] as? [[String:AnyObject]] {
                        // runs if at least one deal already exists
                        
//                        println("deals::::: \(deals)")
                        
                        deals.append(newDeal)
                        
                        currentVenue["venueDeals"] = deals
                        
                        // update singleton
                        ChimeData.mainData().selectedVenue!["venueDeals"] = deals
                        
                    } else {
                        
                        currentVenue["venueDeals"] = [newDeal]
                        
                        // update singleton
                        ChimeData.mainData().selectedVenue!["venueDeals"] = [newDeal]
                        
                    }
                    
                    currentVenue.saveInBackgroundWithBlock({ (success, error) -> Void in
                        
                        if success {
                            println("New deal successfully saved to Parse...")
                            // new deal is saved successfully, pop view controller
                            makeVibrate()
                            self.navigationController?.popViewControllerAnimated(true)
                        } else {
                            println("Error saving deal to Parse: \(error)")
                        }
                        
                    })
                    
                    
                } else {
                    println("Error loading selected venue from Parse while saving: \(error)")
                }
                
            })
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var cellTouched = false
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        var fieldValues: [String] = [describeRewardField.text,additionalDetailsField.text]
        
        // set preview cell to whatever is in the textfield, if anything
        if describeRewardField.text != "" && !cellTouched {
            previewDealLabel.text = describeRewardField.text
            
            if additionalDetailsField.text != "" {
                previewDealLabel.text = describeRewardField.text + "*"
            }

        }
        
        let touchesSet=touches as NSSet
        
        if let touch = touchesSet.allObjects.last as? UITouch {
            
            let location = touch.locationInView(previewCellView)
        
            if location.x >= 0 && location.y >= 0 {
                println("User has clicked on the preview cell...")

                if find(fieldValues, "") == nil {   // would think this would be != nil but...
                    
                    cellTouched = true
                    
                    // alternate the text label for the preview cell
                    if previewDealLabel.text == describeRewardField.text || previewDealLabel.text == describeRewardField.text + "*" {
                        previewDealLabel.text = additionalDetailsField.text
                    } else {
                        previewDealLabel.text = describeRewardField.text + "*"
                    }
                    
                }
                
            }
            
        }
        
        // dismiss keyboard when user touches outside textfields
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)   // ?? is this necessary
    }

}
