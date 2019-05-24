//
//  TableViewCell.swift
//  OnTheMap
//
//  Created by mitch on 5/13/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    // Table Cell layout
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
