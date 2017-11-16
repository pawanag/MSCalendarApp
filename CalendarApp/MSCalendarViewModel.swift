//
//  MSCalendarViewModel.swift
//  CalendarApp
//
//  Created by Pawan on 11/15/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
import EventKit

public typealias pbCompletionHandlerWithResponse = (_ error: Error? , _ responseDictionary: [AnyHashable: Any]?) -> Void

class MSCalendarViewModel: NSObject {

    var isEventAccessGiven : Bool = false
    var eventStore: EKEventStore!
    var defaultCalendar: EKCalendar!
    let weatherManager = MSWeatherManager()

    
     func fetchEvent(index : Int) -> [EKEvent] {
        let startDate = MSDateManager.dateManager.dateForIndex(index: index)
        let endDate = MSDateManager.dateManager.dateForIndex(index: index+1)
        
        // We will only search the default calendar for our events
        let calendarArray: [EKCalendar] = [self.defaultCalendar]
        
        // Create the predicate
        let predicate = self.eventStore.predicateForEvents(withStart: startDate!,
                                                           end: endDate!,
                                                           calendars: calendarArray)
        
        // Fetch all events that match the predicate
        let events = self.eventStore.events(matching: predicate)
        
        return events
    }
    
     func accessGrantedForCalendar(eventStore : EKEventStore) {
        // Let's get the default calendar associated with our event store
        self.eventStore = eventStore
        isEventAccessGiven = true
        defaultCalendar = self.eventStore.defaultCalendarForNewEvents
    }
    
    func fetchWeatherInfoFor(time : String,location : MSLocation, completion: @escaping (WeatherResult) -> Void) {
        DispatchQueue.main.async {
            self.weatherManager.fetchWeather(location: location, time: time) { (weatherResult) in
                completion(weatherResult)
            }
        }
    }
}
