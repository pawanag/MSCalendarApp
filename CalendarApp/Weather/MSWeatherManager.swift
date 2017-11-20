//
//  MSWeatherManager.swift
//  CalendarApp
//
//  Created by Pawan on 11/15/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

// Enum to Decide the weather Category
enum WeatherCategory: String {
    case Clear
    case PartlyCloudy
    case Rain
    case Wind
    case Fog
    case Cloudy
    case Thunderstorm
    
    // Class func to access the Weather Category
    // Input Param String
    static func getCategory(category: String) -> WeatherCategory {
        switch category {
        case MSConstants.kClearDaySmallCase, MSConstants.kClearNightSmallCase, MSConstants.kClearSmallCase:
            return .Clear
        case MSConstants.kPartlyCloudySmallCase, MSConstants.kPartlyCloudyDaySmallCase, MSConstants.kPartlyCloudyNightSmallCase:
            return .PartlyCloudy
        case MSConstants.kCloudySmallCase:
            return .Cloudy
        case MSConstants.kRainSmallCase, MSConstants.kSnowSmallCase, MSConstants.kSleetSmallCase:
            return .Rain
        case MSConstants.kWindSmallCase:
            return .Wind
        case  MSConstants.kFog:
            return .Fog
        default:
            return .Thunderstorm
        }
    }

    func getWeatherStringValue() -> String {
        switch self {
        case .Clear:
            return MSConstants.kClear
        case .Cloudy, .PartlyCloudy:
            return MSConstants.kCloudy
        case .Rain, .Thunderstorm:
            return MSConstants.kRain
        default:
            return MSConstants.kWind
        }
    }
}

enum WeatherResult {
    case success(MSWeather)
    case failure(Error)
}

enum WeatherError: Error {
    case inValidJsonData
}

class MSWeatherManager: NSObject {
    
    private var serviceHandler: MSServiceHandler
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    init(webserviceHandler: MSServiceHandler = MSServiceHandler()) {
        serviceHandler = webserviceHandler
        super.init()
    }
    
    func fetchWeather(location: MSLocation,time: String, completion: @escaping (WeatherResult) -> Void) {
        let url = weatherUrl(fromLatitude: location.latitude, longitude: location.longitude, time: time)
        serviceHandler.fetchWeatherInfo(url: url) { (error, data) in
            guard let jsonData = data else {
                completion(.failure(error!))
                return
            }
            completion(self.weather(fromJSON: jsonData))
        }
    }
    // Get Summary Of weather In string , based on Weather category provided
    
    func getWeatherSummaryFrom(category : WeatherCategory) -> String {
        switch category {
        case .Clear :
            return MSConstants.kClear
        case .PartlyCloudy:
            return MSConstants.kPartlyCloudy
        case .Cloudy:
            return MSConstants.kCloudy
        case .Rain:
            return MSConstants.kRain
        case .Wind:
            return MSConstants.kWind
        case .Fog:
            return MSConstants.kFog
        default:
            return MSConstants.kThunderstorm
        }
    }
    
    // Create URL for fetching the Weather Info particular to a location and based on timestamp
    // 
    func weatherUrl(fromLatitude latitude: String, longitude: String, time: String) -> URL {
        let baseParam = [
            MSConstants.kKeyConstant : MSConstants.apiKey,
            MSConstants.klatitude : latitude,
            MSConstants.klongitude : longitude,
            MSConstants.ktime: time
        ]
        var urlString = MSConstants.baseURLString
        urlString += baseParam[MSConstants.kKeyConstant]! + "/"
        urlString += baseParam[MSConstants.klatitude]! + ","
        urlString += baseParam[MSConstants.klongitude]! + ","
        urlString += baseParam[MSConstants.ktime]!
        
        let components = URLComponents(string: urlString)
        return (components?.url!)!
    }
    
    /** Create MSWeather Type Object and returns it
     @Param Json : response fetched by the API 
     */
    private func weather(fromJSON json: [String: Any]) -> MSWeather? {
        guard let weatherCategory = json[MSConstants.kicon] as? String,
            let summaryValue = json[MSConstants.kSummaryKey] as? String,
            let temperature = json[MSConstants.kTemperatureKey]
            else {
                return nil
        }
        
        let weather = WeatherCategory.getCategory(category: weatherCategory)
        let temperatureStringValue = String(temperature as! Double)
        return MSWeather(category: weather, summary: summaryValue, temperature: temperatureStringValue)
    }
    
    func weather(fromJSON data: Any) -> WeatherResult {
        guard let jsonDictionary = data as? [AnyHashable: Any],
            let weatherDetailJson = jsonDictionary[MSConstants.kCurrentTemperatureKey] as? [String: Any]
            else {
                return .failure(WeatherError.inValidJsonData)
        }
        var finalWeather: MSWeather? = nil
        if let weather = weather(fromJSON: weatherDetailJson) {
            finalWeather = weather
        }
        if finalWeather == nil {
            return .failure(WeatherError.inValidJsonData)
        }
        return .success(finalWeather!)
        
    }
}

