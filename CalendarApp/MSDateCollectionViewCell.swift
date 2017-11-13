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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
                backgroundColor = UIColor.blue
            }
            dateLabel.text = String(dayOfMonth)
            print(dayOfMonth)
        }
    }
}
