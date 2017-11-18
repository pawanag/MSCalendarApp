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
    private var dictionaryModels = [Int:MSDateModel]()
    let locationManager = MSLocationManager.sharedManager

    func fetchModel(indexPath: IndexPath) -> MSDateModel {
        if let model = dictionaryModels[indexPath.row] {
            return model
        } else {
            let model = MSDateModel(index: indexPath.row)
            if isEventAccessGiven {
                if let event = fetchEvent(index: indexPath.row).last {
                   model.eventModel = event
                }                
            }
            weatherFetch(indexPath: indexPath, model: model)
            dictionaryModels[indexPath.row] = model
            return model
        }
    }
    
    private func fetchEvent(index : Int) -> [EKEvent] {
        let startDate = MSDateManager.dateManager.dateForIndex(index: index)
        let endDate = MSDateManager.dateManager.dateForIndex(index: index+1)
        let calendarArray: [EKCalendar] = [self.defaultCalendar]
        let predicate = self.eventStore.predicateForEvents(withStart: startDate!,
                                                           end: endDate!,
                                                           calendars: calendarArray)
        let events = self.eventStore.events(matching: predicate)        
        return events
    }
    
    func accessGrantedForCalendar(eventStore : EKEventStore) {
        // Let's get the default calendar associated with our event store
        self.eventStore = eventStore
        isEventAccessGiven = true
        defaultCalendar = self.eventStore.defaultCalendarForNewEvents
    }
    
    func weatherFetch(indexPath:IndexPath,model: MSDateModel) {
        if let location = locationManager.userLocation {
            let timeInterval = round((MSDateManager.dateManager.dateForIndex(index: indexPath.row)?.timeIntervalSince1970)!) //events time
            let timeInInteger = Int(timeInterval)
            fetchWeatherInfoFor(time: String(timeInInteger),location : location, completion: { (weatherResult) in
                DispatchQueue.main.async {
                    switch weatherResult {
                    case let .success(weather):
                        model.weather = weather
                        break
                    case .failure(_):
                        break
                    }
                }
            })
        }
    }
    
    func fetchWeatherInfoFor(time : String,location : MSLocation, completion: @escaping (WeatherResult) -> Void) {
        DispatchQueue.main.async {
            self.weatherManager.fetchWeather(location: location, time: time) { (weatherResult) in
                completion(weatherResult)
            }
        }
    }
}
