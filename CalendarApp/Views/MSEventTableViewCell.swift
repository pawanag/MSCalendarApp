//
//  MSEventTableViewCell.swift
//  CalendarApp
//
//  Created by Pawan on 11/10/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
import EventKit

class MSEventTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

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
        backgroundColor = UIColor.white
        eventTitleLabel.textColor = UIColor.lightGray
        
    }
    
    func setValues(indexPath: IndexPath) {
        _ = MSDateManager.dateManager.dateForIndex(index: indexPath.row)
        if let dayOfMonth = dateHelper.dayOfMonthFor(index: indexPath.row){
            if dayOfMonth == 1 {
                titleLabel.isHidden = false
                subTitleLabel.isHidden = false
                titleLabel.text = dateHelper.yearStringFor(index: indexPath.row)
                backgroundColor = UIColor.blue
            }
            titleLabel.text = dateHelper.sectionTitleFor(index: indexPath.row)
            temperatureLabel.text = " - - "
        }
    }
    
    func setEventInfo(events : [EKEvent]) {
        if events.count > 0 {
            // show event to calendar
            for event in events {
                eventTitleLabel.text = event.title
                eventTitleLabel.textColor = UIColor.black

            }
        } else {
            eventTitleLabel.text = "No Event"
            eventTitleLabel.textColor = UIColor.lightGray
        }
    }
    func setWeatherInfo(weather : MSWeather) {
            temperatureLabel.text = weather.temperature + " " +  MSWeatherManager().getWeatherSummaryFrom(category : weather.category)
        
    }
}
