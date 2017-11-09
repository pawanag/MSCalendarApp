//
//  MSEventTableViewCell.swift
//  CalendarApp
//
//  Created by Pawan on 11/10/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

class MSEventTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var indicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
