//
//  CustomButton.swift
//  BajaCheckers
//
//  Created by Michael McChesney on 2/17/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {

//    let btnWidth: CGFloat =
    
//    @IBInspectable var cornerSize: CGFloat = 0
//    @IBInspectable var borderColor: UIColor = UIColor.clearColor()
//    @IBInspectable var borderWidth: CGFloat = 0


    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
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
//        CGContextStrokeRectWithWidth(ctx, rect, 2)
    
//        self.layer.borderColor =
    
    }
    

}
