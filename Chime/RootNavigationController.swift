//
//  RootNavigationController.swift
//  Chime
//
//  Created by Michael McChesney on 3/3/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

// global function to make phone vibrate
func makeVibrate() {
    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
}

// array of imageViews
var navImageViews: [UIImageView] = []

protocol segmentedControllerDidChangeProtocol {
    func segmentedControllerDidChange(value: Int)
}


class RootNavigationController: UINavigationController {

    var sC =  UISegmentedControl(items: ["Nearby", "New"])
    
    var delegate2: segmentedControllerDidChangeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // load background image w/ gradient.
        let bgImageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        let bgImage = UIImage(named: "bgGradient")
        bgImageView.image = bgImage
        view.insertSubview(bgImageView, atIndex: 0)
        
        ////////
        //////// CUSTOMIZE NAVBAR
        ////////
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationBar.shadowImage = UIImage()  // removes the seperating line from the navbar (optional)
        self.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationBar.tintColor = UIColor.whiteColor()
        
        ////////
        //////// CUSTOMIZE TOOLBAR - ?? do I have 2 toolbars on top of each other with this method?
        ////////
        let tB = self.toolbar
        
        // make background clear
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Bottom, barMetrics: .Default)
        tB.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Bottom, barMetrics: .Default)
        tB.backgroundColor = UIColor(red:0.47, green:0.58, blue:0.68, alpha:1)
        
        //make segment control btn
        sC.frame = CGRectMake(0, 0, 250, 30)
        sC.center = CGPointMake(tB.center.x, 22)
        sC.selectedSegmentIndex = 0
        sC.alpha = 0.85
        sC.tintColor = UIColor.whiteColor()
        sC.addTarget(self, action: "selectedControllerDidChange", forControlEvents: .ValueChanged)

        // add toolbar and segment control views
        tB.addSubview(sC)
        
        //create navbar images
        createImages()

    }
    
    func createImages() {
        
        // make images for navbar
        let images = ["shotGlass","pintGlass","wineGlass","wineGlasses","beerMug"]
        for (i,imageName) in enumerate(images) {
            
            let backButtonSize: CGFloat = 100
            let sWidth: CGFloat = UIScreen.mainScreen().bounds.width
            let width: CGFloat = sWidth - backButtonSize
            let height: CGFloat = 45
            let imageWidth: CGFloat = 30
            let imageHeight: CGFloat = 30
            let margin: CGFloat = (width - (imageWidth * CGFloat(images.count))) / CGFloat(images.count + 1)
            
            let imageX = backButtonSize + (CGFloat(i) * (imageWidth + margin))
            
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(imageX, height - imageHeight, imageWidth, imageHeight)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            navImageViews.append(imageView)
            
        }
    }
    
    func selectedControllerDidChange() {

        var selectedSegment = sC.selectedSegmentIndex
        if selectedSegment == 0 {
            self.delegate2?.segmentedControllerDidChange(0)
        }
            
        if selectedSegment == 1 {
            self.delegate2?.segmentedControllerDidChange(1)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
