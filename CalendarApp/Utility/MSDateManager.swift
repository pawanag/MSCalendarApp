//
//  MSDateManager.swift
//  CalendarApp
//
//  Created by Pawan on 11/9/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

final class MSDateManager {
    
let kSecondsInDay = (24*60*60)
let kSecondsInFiveYears = (5*365*24*60*60)
    
  static let dateManager = MSDateManager()
    var startDate : Date!
    var endDate : Date!
   
    private init() {
        setInitialDates()
    }
    
    private func setInitialDates() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: MSConstants.kLocaleTimeIdentifier)
        let todaysDateInMilliSeconds = Int(Date().timeIntervalSince1970)
        let dateFiveYearsAgo = (todaysDateInMilliSeconds - kSecondsInFiveYears)
        let dateAfterFiveYears = (todaysDateInMilliSeconds + kSecondsInFiveYears)
        // Creating date 5 years ago and after from today
        startDate = Date(timeIntervalSince1970: TimeInterval(dateFiveYearsAgo))
        endDate = Date(timeIntervalSince1970: TimeInterval(dateAfterFiveYears))
    }
    
    func indexForDate(date : Date) -> Int {
        if date.compare(endDate) == ComparisonResult.orderedDescending || date.compare(startDate) == ComparisonResult.orderedAscending {
        }
        return (Int(date.timeIntervalSince(startDate))) / Int(kSecondsInDay)
    }

    // This Method would give Index for Today's Date
    func indexForToday() -> Int {
        return indexForDate(date: Date())
    }
    // Total Days between the Start date and the End Date
    func totalDays() -> Int {
        return Int(endDate.timeIntervalSince(startDate)/Double(kSecondsInDay))
    }
    
    // This method returns Date based on the Index Provided
    func dateForIndex(index : Int) -> Date? {
        let date = startDate.addingTimeInterval(TimeInterval(index * kSecondsInDay))
        if date.compare(endDate) == ComparisonResult.orderedDescending {
            return nil
        }
        return date
    }
    
}
