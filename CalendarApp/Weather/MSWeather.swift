//
//  MSWeather.swift
//  CalendarApp
//
//  Created by Pawan on 11/15/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

class MSWeather: NSObject {
    let category: WeatherCategory
    let summary: String
    let temperature: String
    
    init(category: WeatherCategory, summary: String, temperature: String) {
        self.category = category
        if let temperatureInDouble = Double(temperature) {
            let tempInCelsius = (temperatureInDouble - 32)*(5/9)
            self.temperature = String(format: "%.0f", ceil(tempInCelsius*100)/100) + " °C"
        } else {
            self.temperature = "temperature"
        }
        
        self.summary = summary
    }
}
