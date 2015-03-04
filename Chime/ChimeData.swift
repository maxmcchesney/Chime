//
//  ChimeData.swift
//  Chime
//
//  Created by Michael McChesney on 3/4/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

let _mainData: ChimeData = ChimeData()

import UIKit

class ChimeData: NSObject {
    // Singleton model
    
    
    
    
    class func mainData() -> ChimeData {
        
        return _mainData
        
    }
   
}
