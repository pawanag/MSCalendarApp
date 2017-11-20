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
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventDurationLabel: UILabel!
    @IBOutlet weak var eventStartTime: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var noEventView: UIView!
    
    @IBOutlet weak var noEventLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    let dateHelper = MSDateHelper()
    /* Adding and Removing Observer so that the changes are reflected on cell
       once the weather data is fetched */
    
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

    // KVO Observer so as to update the data
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "weather" {
            if let weather = model.weather {
                
                // getting access of main queue before doing any UI Operations
                DispatchQueue.main.async {
                    self.temperatureLabel.text = weather.temperature + " " +  MSWeatherManager().getWeatherSummaryFrom(category : weather.category)
                }
            }
        }
    }
    
    // Resetting Cell to it's default values, so that they are available for reuse

    private func resetToDefaultValues() {
        titleLabel.text = ""
        eventTitleLabel.text = ""
        eventStartTime.text = ""
        eventDurationLabel.text = ""
        eventLocationLabel.text = ""
        backgroundColor = UIColor.white
        indicatorView.isHidden = true
        locationImageView.isHidden = true
        noEventLabel.text = ""
        eventTitleLabel.textColor = UIColor.lightGray
    }
    
    func setValues() {
        resetToDefaultValues()
        model.addObserver(self, forKeyPath: "weather", options: [.old, .new, .initial], context: nil)

        if let day = model.day {
            if day == "1" {
                titleLabel.isHidden = false
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
    
    // Configuring  Cell based on Event Info available
    func setEventInfo() {
        if let event = model.eventModel {
            eventTitleLabel.text = event.title
            eventTitleLabel.textColor = UIColor.black
            eventStartTime.text = Date.date(event.startDate, inFormat: "hh : mm")
            let timeDuartion = event.endDate.timeIntervalSince1970 - event.startDate.timeIntervalSince1970
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: Int(timeDuartion))
            if m>0 || s > 0 {
                eventDurationLabel.text = "\(h)h \(m)m \(s)s"
            } else {
                eventDurationLabel.text = "\(h)h"
            }
            if let location = event.location , location != "" {
                eventLocationLabel.text = location
                locationImageView.isHidden = false
            }  else {
                locationImageView.isHidden = true
            }
            
            indicatorView.isHidden = false
        } else {
            noEventLabel.text = "No Event"
            noEventLabel.textColor = UIColor.lightGray
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func setWeatherInfo(weather : MSWeather) {
        temperatureLabel.text = weather.temperature + " " +  MSWeatherManager().getWeatherSummaryFrom(category : weather.category)
        
    }
}
