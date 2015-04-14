//
//  SpringAnimation.swift
//  ShotsDemo
//
//  Created by Meng To on 2014-07-04.
//  Copyright (c) 2014 Meng To. All rights reserved.
//

import UIKit

var duration = 0.7
var delay = 0.0
var damping = 0.7
var velocity = 0.7


// uses predetermined attributes for spring
// animations is a closure (function that takes no argument and returns nothing so the animation appens and end of function when completion (since it take no argument not necessary to pass it as an argument)
func spring(duration: NSTimeInterval, animations: (() -> Void)!) {
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: nil, animations: {
        // animations = (() -> Void)!)
        animations()
        
        }, completion: { finished in
            
        })
}

func animationWithDuration(duration: NSTimeInterval, animations: (() -> Void)!) {
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: nil, animations: {
        
        animations()
        
        }, completion: { finished in
            
    })
}

func springWithDelay(duration: NSTimeInterval, delay: NSTimeInterval, animations: (() -> Void)!) {
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: nil, animations: {
        
        animations()
        
        }, completion: { finished in
            
        })
}

func slideUp(duration: NSTimeInterval, animations: (() -> Void)!) {
    UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: nil, animations: {
        
        animations()
        
        }, completion: nil)
}

func springWithCompletion(duration: NSTimeInterval, animations: (() -> Void)!, completion: ((Bool) -> Void)!) {
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: nil, animations: {
        
        animations()
        
        }, completion: { finished in
            completion(true)
        })
}

func springScaleFrom (view: UIView, x: CGFloat, y: CGFloat, scaleX: CGFloat, scaleY: CGFloat) {
    let translation = CGAffineTransformMakeTranslation(x, y)
    let scale = CGAffineTransformMakeScale(scaleX, scaleY)
    view.transform = CGAffineTransformConcat(translation, scale)
    
    UIView.animateWithDuration(2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: nil, animations: { // duration was 0.7 and delay was 0
        
        let translation = CGAffineTransformMakeTranslation(0, 0)
        let scale = CGAffineTransformMakeScale(1, 1)
        view.transform = CGAffineTransformConcat(translation, scale)
        
        }, completion: nil)
}

func springScaleTo (view: UIView, x: CGFloat, y: CGFloat, scaleX: CGFloat, scaleY: CGFloat) {
    let translation = CGAffineTransformMakeTranslation(0, 0)
    let scale = CGAffineTransformMakeScale(1, 1)
    view.transform = CGAffineTransformConcat(translation, scale)
    
    UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: nil, animations: {
        
        let translation = CGAffineTransformMakeTranslation(x, y)
        let scale = CGAffineTransformMakeScale(scaleX, scaleY)
        view.transform = CGAffineTransformConcat(translation, scale)
        
        }, completion: nil)
}

func popoverTopRight(view: UIView) {
    view.hidden = false
    var translate = CGAffineTransformMakeTranslation(200, -200)
    var scale = CGAffineTransformMakeScale(0.3, 0.3)
    view.alpha = 0
    view.transform = CGAffineTransformConcat(translate, scale)
    
    UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: {  // duration was 0.6
        
        var translate = CGAffineTransformMakeTranslation(0, 0)
        var scale = CGAffineTransformMakeScale(1, 1)
        view.transform = CGAffineTransformConcat(translate, scale)
        view.alpha = 1
        
        }, completion: nil)
}