//
//  CustomButton.swift
//  BajaCheckers
//
//  Created by Michael McChesney on 2/17/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton {

    @IBInspectable var cornerSize: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.clearColor()
    @IBInspectable var borderWidth: CGFloat = 0


    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    
        self.layer.cornerRadius = cornerSize
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = borderWidth
        
        self.layer.masksToBounds = true
    
    }
    

}
