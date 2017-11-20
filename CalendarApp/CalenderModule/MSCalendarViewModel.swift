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
    var defaultCalendar: EKCalendar?
    let weatherManager: MSWeatherManager
    let locationManager: MSLocationManager
    private var dictionaryModels = [Int:MSDateModel]()
    @objc dynamic var isEventSaved : Bool = false
    
    init(_ weatherManager: MSWeatherManager = MSWeatherManager(),locationManager: MSLocationManager = MSLocationManager.sharedManager) {
        self.weatherManager = weatherManager
        self.locationManager = locationManager
    }
    
    // Fetching Model for the Indexpath
    func fetchModel(indexPath: IndexPath) -> MSDateModel {
        if let model = dictionaryModels[indexPath.row], model.weather != nil {
            return model
        } else {
            let model = MSDateModel(index: indexPath.row)
            if isEventAccessGiven {
                if let event = fetchEvent(index: indexPath.row)?.last {
                   model.eventModel = event
                }                
            }
            weatherFetch(indexPath: indexPath, model: model)
            dictionaryModels[indexPath.row] = model
            return model
        }
    }
    
    // Fetch Event for that Day
    private func fetchEvent(index : Int) -> [EKEvent]? {
        guard let defaultCalendar = defaultCalendar else {
            return nil
        }
        let startDate = MSDateManager.dateManager.dateForIndex(index: index)
        let calendarArray: [EKCalendar] = [defaultCalendar]
        let predicate = self.eventStore.predicateForEvents(withStart: startDate!,
                                                           end: startDate!,
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
        guard model.weather == nil else {
            return
        }
        if let location = locationManager.userLocation {
            let timeInterval = round((MSDateManager.dateManager.dateForIndex(index: indexPath.row)?.timeIntervalSince1970)!) //events time
            let timeInInteger = Int(timeInterval)
            fetchWeather(info: String(timeInInteger),location : location, completion: { (weatherResult) in
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
    
    // Static Event to be created and Saved
    func createEventForToday() {
        guard let calendar = defaultCalendar else {
            return
        }
        
        let todaysDateInMilliSeconds = Int(Date().timeIntervalSince1970)
        
        let event = EKEvent(eventStore: self.eventStore)
        event.title = "Microsoft iOS Dev Event"
        event.startDate = Date(timeIntervalSince1970: TimeInterval(todaysDateInMilliSeconds - (6*60*60)))
        event.endDate = Date(timeIntervalSince1970: TimeInterval(todaysDateInMilliSeconds + (6*60*60)))
        event.notes = "This is a test Microsoft iOS Dev Event"
        event.location = " Microsoft Bangalore Office"
        event.calendar = calendar
        do {
            try self.eventStore.save(event, span: EKSpan(rawValue: 0)!)
            isEventSaved = true
        } catch {
            print("error in creating Event")
        }
    }
    
    func fetchWeather(info time : String,location : MSLocation, completion: @escaping (WeatherResult) -> Void) {
            self.weatherManager.fetchWeather(location: location, time: time) { (weatherResult) in
                completion(weatherResult)
            }
    }
}
