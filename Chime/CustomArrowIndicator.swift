//
//  CustomArrowIndicator.swift
//  Chime
//
//  Created by Michael McChesney on 3/18/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

@IBDesignable class CustomArrowIndicator: UIView {

    @IBInspectable var strokeColor: UIColor = UIColor.darkGrayColor()
    @IBInspectable var lineWidth: CGFloat = 1
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    
        let ctx = UIGraphicsGetCurrentContext()
        
        strokeColor.set()
        
        CGContextMoveToPoint(ctx, 0, 0)
        CGContextAddLineToPoint(ctx, rect.maxX, rect.midY)
        CGContextAddLineToPoint(ctx, 0, rect.maxY)
        CGContextSetLineCap(ctx, kCGLineCapRound)
        CGContextSetLineJoin(ctx, kCGLineJoinRound)
        CGContextSetLineWidth(ctx, lineWidth)
        CGContextStrokePath(ctx)
    
    
    
    }
    

}

@IBDesignable class CustomDownArrow: UIView {
    
    @IBInspectable var strokeColor: UIColor = UIColor(red:0.29, green:0.56, blue:0.89, alpha:1)
    @IBInspectable var lineWidth: CGFloat = 1
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        let ctx = UIGraphicsGetCurrentContext()
        
        strokeColor.set()
        
        CGContextMoveToPoint(ctx, 0, 0)
        CGContextAddLineToPoint(ctx, rect.midX, rect.maxY)
        CGContextAddLineToPoint(ctx, rect.maxX, rect.minY)
        CGContextSetLineCap(ctx, kCGLineCapRound)
        CGContextSetLineJoin(ctx, kCGLineJoinRound)
//        CGContextSetLineWidth(ctx, lineWidth)
        CGContextFillPath(ctx)
//        CGContextStrokePath(ctx)
        
        
        
    }
    
    
}
