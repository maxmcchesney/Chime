//
//  DealCell.swift
//  Chime
//
//  Created by Michael McChesney on 3/4/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class DealCell: UITableViewCell {
    
    @IBOutlet weak var tagTimeLabel: UILabel!
    @IBOutlet weak var tagValueLabel: UILabel!
    
    @IBOutlet weak var tagView: UIView!
    
    @IBOutlet weak var dealLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
