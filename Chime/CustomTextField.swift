//
//  CustomTextField.swift
//  GetTurnt
//
//  Created by Michael McChesney on 2/12/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

@IBDesignable class CustomTextField: UITextField {
    
    @IBInspectable var borderColor:UIColor = UIColor.clearColor()
    @IBInspectable var borderWidth: CGFloat = 0
    
    @IBInspectable var cornerSize: CGFloat = 0

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    
        self.layer.masksToBounds = true
        
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.CGColor
        
        self.layer.cornerRadius = cornerSize
    
    }
    

}
