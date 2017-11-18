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
    
  static let dateManager = MSDateManager()
    var startDate : Date!
    var endDate : Date!
   
    private init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        startDate = dateFormatter.date(from: "Jan 1, 2010")
        endDate = dateFormatter.date(from: "Dec 31, 2030")

        var tempDate = startDate
        let dayOfWeek = Calendar.current.component(Calendar.Component.weekday, from: startDate)
        if dayOfWeek != 1 {
            // If it is not a Sunday, then find the nearest previous date which falls on Sunday
            var offsetComponents = DateComponents()
            offsetComponents.day = (dayOfWeek - 1)
            tempDate = Calendar.current.date(byAdding: offsetComponents, to: startDate)
        }
        startDate = tempDate
    }
    
    func indexForDate(date : Date) -> Int {
        if date.compare(endDate) == ComparisonResult.orderedDescending || date.compare(startDate) == ComparisonResult.orderedAscending {
//            var exception: NSException = NSException(name: NSRangeException, reason: "Date provided is outside the range of start and end dates", userInfo: nil)
//            exception.raise()
        }
        return (Int(date.timeIntervalSince(startDate))) / Int(kSecondsInDay)
    }

    
    func indexForToday() -> Int {
        return indexForDate(date: Date())
    }
    
    func totalDays() -> Int {
        return Int(endDate.timeIntervalSince(startDate)/Double(kSecondsInDay))
    }
    
    func dateForIndex(index : Int) -> Date? {
        let date = startDate.addingTimeInterval(TimeInterval(index * kSecondsInDay))
        if date.compare(endDate) == ComparisonResult.orderedDescending {
            return nil
        }
        return date
    }
    
}
