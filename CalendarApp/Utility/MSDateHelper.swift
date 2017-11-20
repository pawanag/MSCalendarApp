//
//  MSDateHelper.swift
//  CalendarApp
//
//  Created by Pawan on 11/10/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

class MSDateHelper: NSObject {

    // Helper Class to convert dates into specified Format
    
    var dateFormatter : DateFormatter
    let dateManager = MSDateManager.dateManager
    
    override init() {
       dateFormatter =  DateFormatter()
        dateFormatter.locale = Locale(identifier: MSConstants.kLocaleTimeIdentifier)
    }
    
    func monthStringFor(index : Int)-> String? {
        if let date = dateManager.dateForIndex(index: index) {
            dateFormatter.dateFormat = "MMM"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func monthStringCompleteFor(index : Int)-> String? {
        if let date = dateManager.dateForIndex(index: index) {
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func yearStringFor(index : Int)-> String? {
        if let date = dateManager.dateForIndex(index: index) {
            dateFormatter.dateFormat = "YYYY"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func titleStringFor(index : Int)-> String? {
        if let date = dateManager.dateForIndex(index: index) {
            dateFormatter.dateFormat = "MMM y"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    func dayOfMonthFor(index : Int)-> Int? {
        if let date = dateManager.dateForIndex(index: index) {
            dateFormatter.dateFormat = "d"
            let dateString = dateFormatter.string(from: date)
            return Int(dateString)
        }
        return nil
    }
    
    func sectionTitleFor(index : Int)-> String? {
        if let date = dateManager.dateForIndex(index: index) {
            dateFormatter.dateFormat = "EEEE, d MMMM y"
            
            let todayIndex = dateManager.indexForToday()
            if index == todayIndex - 1 {
                return "Yesterday, " + dateFormatter.string(from: date)
            } else if index == todayIndex {
                return "Today, " + dateFormatter.string(from: date)
            } else if index == todayIndex + 1 {
                return "Tomorrow, " + dateFormatter.string(from: date)
            } else {
                return dateFormatter.string(from: date)
            }
        }
        return nil
    }
    
    func keyStringForIndex(index : Int) -> String? {
        if let date = dateManager.dateForIndex(index: index) {
            dateFormatter.dateFormat = "d MMMM y"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
}
