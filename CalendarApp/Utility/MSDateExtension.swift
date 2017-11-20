//
//  MSDateExtension.swift
//  CalendarApp
//
//  Created by Pawan on 11/20/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import Foundation

extension Date {
    
    fileprivate static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.ReferenceType.default
        formatter.locale = Locale.init(identifier: MSConstants.kLocaleTimeIdentifier)
        return formatter
    }()
    
    // Extension method on Date which Gives us the Date in String format
    static func date(_ date: Date, inFormat: String) -> String? {
        formatter.dateFormat = inFormat
        return formatter.string(from: date)
    }
}
