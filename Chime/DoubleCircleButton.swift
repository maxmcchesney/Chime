//
//  DoubleCircleButton.swift
//  BajaCheckers
//
//  Created by Michael McChesney on 2/17/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

@IBDesignable class DoubleCircleButton: UIButton {

    @IBInspectable var bottomColor: UIColor = UIColor(red:0.98, green:0.49, blue:0.2, alpha:1)
    @IBInspectable var bottomColorAlpha: CGFloat = 1.0
    @IBInspectable var middleColor: UIColor = UIColor(red:0.98, green:0.85, blue:0.38, alpha:1)
    @IBInspectable var middleColorAlpha: CGFloat = 0.8
    @IBInspectable var topColor: UIColor = UIColor(red:0.98, green:0.85, blue:0.38, alpha:1)
    @IBInspectable var topColorAlpha: CGFloat = 0.8
    
    var dealAvailable: Bool = false {
        
        didSet {
            
            setNeedsDisplay()
            
        }
        
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        let btnWidth: CGFloat = rect.width
        let btnHeight: CGFloat = rect.height
        let margin: CGFloat = 5

        self.layer.cornerRadius = btnWidth / 2
        self.layer.masksToBounds = true
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let deactivatedColor = UIColor.grayColor()
        deactivatedColor.set()
        
        self.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        
        let innerCircle = CGRectMake(margin / 2, margin / 2, btnWidth - margin, btnHeight - margin)
        CGContextFillEllipseInRect(ctx, innerCircle)
        
        CGContextStrokeEllipseInRect(ctx, rect)
        
        // change appearance of button if deal becomes available
        if dealAvailable {
            
            // set up gradient
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = innerCircle
            gradientLayer.cornerRadius = (btnHeight - margin) / 2
            gradientLayer.masksToBounds = true
            let c1 = bottomColor.colorWithAlphaComponent(bottomColorAlpha).CGColor
            let c2 = middleColor.colorWithAlphaComponent(middleColorAlpha).CGColor
            let c3 = topColor.colorWithAlphaComponent(topColorAlpha).CGColor
            gradientLayer.colors = [c3, c2, c1]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            self.layer.insertSublayer(gradientLayer, atIndex: 0)
            
            self.setTitleColor(UIColor.orangeColor(), forState: .Normal)
            UIColor.blueColor().set()
            CGContextStrokeEllipseInRect(ctx, rect)
            
        }
    
    }
    

}
