//
//  MSDateModule.swift
//  CalendarApp
//
//  Created by Pawan on 11/18/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
import EventKit

class MSDateModel: NSObject {
    var day: String?
    var month: String?
    var year: String?
    var date: String?
    var titleMonth : String?
    var cellSelection: CellSelection = .none
    var eventModel: EKEvent?
    // Property Created as Dynamic so that KVO Could be applied
    @objc dynamic var weather: MSWeather?

    init(index: Int) {
        let dateHelper = MSDateHelper()
        if let dayOfMonth = dateHelper.dayOfMonthFor(index: index){
            // Accessing Month and Year Only for first date
            if dayOfMonth == 1 {
                month = dateHelper.monthStringFor(index: index)
                year = dateHelper.yearStringFor(index: index)
            }
            titleMonth = dateHelper.monthStringCompleteFor(index:index)
            date = dateHelper.sectionTitleFor(index: index)
            day = String(dayOfMonth)
        }
    }
}
