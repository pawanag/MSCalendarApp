//
//  MSDateCollectionViewCell.swift
//  CalendarApp
//
//  Created by Pawan on 11/9/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

class MSDateCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    let dateHelper = MSDateHelper()
    @IBOutlet weak var lineView: UIView!

    @IBOutlet weak var lineViewHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        lineViewHeight.constant = 0.5

    }

    func resetToDefaultValues() {
        monthLabel.text = ""
        dateLabel.text = ""
        yearLabel.text = ""
        backgroundColor = UIColor.white
    }
    
    func setValues(indexPath: IndexPath) {
        _ = MSDateManager.dateManager.dateForIndex(index: indexPath.row)
        if let dayOfMonth = dateHelper.dayOfMonthFor(index: indexPath.row){
            
            if dayOfMonth == 1 {
                monthLabel.isHidden = false
                yearLabel.isHidden = false
                monthLabel.text = dateHelper.monthStringFor(index: indexPath.row)
                yearLabel.text = dateHelper.yearStringFor(index: indexPath.row)
                backgroundColor = UIColor.lightGray
            }
            dateLabel.text = String(dayOfMonth)
            print(dayOfMonth)
        }
    }
}
