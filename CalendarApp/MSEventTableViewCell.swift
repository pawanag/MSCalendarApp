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
    @IBOutlet weak var eventTitleLabel: UILabel!
    let dateHelper = MSDateHelper()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resetToDefaultValues() {
        titleLabel.text = ""
        subTitleLabel.text = ""
        eventTitleLabel.text = ""
//        yearLabel.text = ""
        backgroundColor = UIColor.white
        
    }
    
    func setValues(indexPath: IndexPath) {
        _ = MSDateManager.dateManager.dateForIndex(index: indexPath.row)
        if let dayOfMonth = dateHelper.dayOfMonthFor(index: indexPath.row){
            
            if dayOfMonth == 1 {
                titleLabel.isHidden = false
                subTitleLabel.isHidden = false
//                subTitleLabel.text = dateHelper.monthStringFor(index: indexPath.row)
                titleLabel.text = dateHelper.yearStringFor(index: indexPath.row)
                backgroundColor = UIColor.blue
            }
            titleLabel.text = dateHelper.sectionTitleFor(index: indexPath.row)
            subTitleLabel.text = String(dayOfMonth)
            print(dayOfMonth)
        }
    }
}
