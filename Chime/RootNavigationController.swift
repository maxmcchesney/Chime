//
//  RootNavigationController.swift
//  Chime
//
//  Created by Michael McChesney on 3/3/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

// array of imageViews
var navImageViews: [UIImageView] = []

class RootNavigationController: UINavigationController {

//    // array of imageViews
//    var navImageViews: [UIImageView] = []
    
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
//        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationBar.tintColor = UIColor.whiteColor()

        let images = ["shotGlass","pintGlass","wineGlass","wineGlasses","beerMug"]
        
        // make images for navbar

        for (i,imageName) in enumerate(images) {
        
            let backButtonSize: CGFloat = 100
            let sWidth: CGFloat = UIScreen.mainScreen().bounds.width
            let width: CGFloat = sWidth - backButtonSize
            let height: CGFloat = 45
            let imageWidth: CGFloat = 30
            let imageHeight: CGFloat = 30
            let margin: CGFloat = (width - (imageWidth * CGFloat(images.count))) / CGFloat(images.count + 1)
            
            println(margin)
            
            let imageX = backButtonSize + (CGFloat(i) * (imageWidth + margin))
            
            println(imageX)
            
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRectMake(imageX, height - imageHeight, imageWidth, imageHeight)
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            navImageViews.append(imageView)
            
        }
        
        ////////
        //////// CUSTOMIZE TOOLBAR - ?? do I have 2 toolbars on top of each other with this method?
        ////////
        let tB = self.toolbar
        
//        UIToolbar(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - 44, UIScreen.mainScreen().bounds.width, 44))
        
        // make background clear
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Bottom, barMetrics: .Default)
        tB.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Bottom, barMetrics: .Default)
        tB.backgroundColor = UIColor(red:0.47, green:0.58, blue:0.68, alpha:1)
        
        //make segment control btn
        let sC = UISegmentedControl(items: ["Nearby", "New"])
        sC.frame = CGRectMake(0, 0, 175, 25)
        sC.center = CGPointMake(tB.center.x, 22)
        sC.selectedSegmentIndex = 0
        sC.alpha = 0.85
        sC.tintColor = UIColor.whiteColor()

        // add toolbar and segment control views
        tB.addSubview(sC)

        
        
        
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
