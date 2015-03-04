//
//  VenueCell.swift
//  Chime
//
//  Created by Michael McChesney on 3/3/15.
//  Copyright (c) 2015 Max McChesney. All rights reserved.
//

import UIKit

class VenueCell: UITableViewCell {

    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var venueNeighborhood: UILabel!
    
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
