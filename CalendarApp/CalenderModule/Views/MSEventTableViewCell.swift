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
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    let dateHelper = MSDateHelper()
    var model: MSDateModel! {
        willSet {
            if model != nil {
                model.removeObserver(self, forKeyPath: "weather")
            }
        }
        didSet {
            setValues()
        }
    }

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "weather" {
            if let weather = model.weather {
                DispatchQueue.main.async {
                    self.temperatureLabel.text = weather.temperature
                }
            }
        }
    }
    
    private func resetToDefaultValues() {
        titleLabel.text = ""
        subTitleLabel.text = ""
        eventTitleLabel.text = ""
        backgroundColor = UIColor.white
        eventTitleLabel.textColor = UIColor.lightGray
    }
    
    func setValues() {
        resetToDefaultValues()
        model.addObserver(self, forKeyPath: "weather", options: [.old, .new, .initial], context: nil)

        if let day = model.day {
            if day == "1" {
                titleLabel.isHidden = false
                subTitleLabel.isHidden = false
            }
            titleLabel.text = model.date
        }
        if let weather = model.weather {
            temperatureLabel.text = weather.temperature
        } else {
            temperatureLabel.text = " - - "
        }
        setEventInfo()
    }
    
    func setEventInfo() {
        if let event = model.eventModel {
            eventTitleLabel.text = event.title
            eventTitleLabel.textColor = UIColor.black
        } else {
            eventTitleLabel.text = "No Event"
            eventTitleLabel.textColor = UIColor.lightGray
        }
    }
    
    func setWeatherInfo(weather : MSWeather) {
        temperatureLabel.text = weather.temperature + " " +  MSWeatherManager().getWeatherSummaryFrom(category : weather.category)
        
    }
}
