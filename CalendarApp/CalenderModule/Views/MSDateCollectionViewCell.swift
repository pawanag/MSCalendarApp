//
//  MSDateCollectionViewCell.swift
//  CalendarApp
//
//  Created by Pawan on 11/9/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

enum CellSelection {
    case none
    case partialSelected
    case selected
    case today
}

class MSDateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var lineViewHeight: NSLayoutConstraint!
    
    var model: MSDateModel! {
        didSet {
            setValues()
        }
    }
   
    // configuring cell based on it's Selected state
    var cellSelection: CellSelection = .none {
        didSet {
            switch cellSelection {
            case .none:
                circleView.isHidden = true
                if let day = model.day {
                    if day == "1" {
                        monthLabel.isHidden = false
                    }
                }
                dateLabel.textColor =  UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
            case .partialSelected:
                monthLabel.isHidden = true
                circleView.isHidden = false
                dateLabel.textColor = UIColor.white
                circleView.backgroundColor = UIColor(red: 175/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1.0)
            case .selected:
                monthLabel.isHidden = true
                dateLabel.textColor = UIColor.white
                circleView.isHidden = false
                circleView.backgroundColor = UIColor(red: 74/255.0, green: 85/255.0, blue: 247/255.0, alpha: 1.0)
            case .today:
                dateLabel.textColor = UIColor.white
                circleView.isHidden = false
                circleView.backgroundColor = UIColor(red: 74/255.0, green: 85/255.0, blue: 247/255.0, alpha: 1.0)
            }
        }
    }

    func setValues() {
        circleView.layer.cornerRadius = (self.frame.size.height-16)/2.0
        resetToDefaultValues()
        if let day = model.day {
            if day == "1" {
                monthLabel.isHidden = false
                monthLabel.text = model.month ?? ""
            }
            dateLabel.text = day
        }
        cellSelection = model.cellSelection
    }
    
    // Resetting Cell to it's default values, so that they are available for reuse
    private func resetToDefaultValues() {
        dateLabel.textColor =  UIColor(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1.0)
        circleView.isHidden = true
        monthLabel.text = ""
        dateLabel.text = ""
        backgroundColor = UIColor.white
    }
}

