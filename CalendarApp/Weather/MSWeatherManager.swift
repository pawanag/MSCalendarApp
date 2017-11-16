//
//  MSWeatherManager.swift
//  CalendarApp
//
//  Created by Pawan on 11/15/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

enum WeatherCategory: String {
    case Clear
    case PartlyCloudy
    case Rain
    case Wind
    case Fog
    case Cloudy
    case Thunderstorm
    
    static func getCategory(category: String) -> WeatherCategory {
        switch category {
        case "clear-day", "clear-night", "clear":
            return .Clear
        case "partly-cloudy", "partly-cloudy-day", "partly-cloudy-night":
            return .PartlyCloudy
        case "cloudy":
            return .Cloudy
        case "rain", "snow", "sleet":
            return .Rain
        case "wind":
            return .Wind
        case "fog":
            return .Fog
        default:
            return .Thunderstorm
        }
    }
    
    
    
    func getWeatherStringValue() -> String {
        switch self {
        case .Clear:
            return "Clear"
        case .Cloudy, .PartlyCloudy:
            return "Cloudy"
        case .Rain, .Thunderstorm:
            return "Rain"
            
        default:
            return "Windy"
        }
    }
}

enum WeatherResult {
    case success(MSWeather) //associated value
    case failure(Error)
}

enum WeatherError: Error {
    case inValidJsonData
}

class MSWeatherManager: NSObject {

    private let baseURLString = "https://api.darksky.net/forecast/"
    private let apiKey = "5f709641557cdd468ee3cbc9001aa437"
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    
    func fetchWeather(location: MSLocation,time: String, completion: @escaping (WeatherResult) -> Void) {
        let url = weatherUrl(fromLatitude: location.latitude, longitude: location.longitude, time: time)
        
        let urlRequest = URLRequest(url: url) //url , method, parameter, headers
        let task = session.dataTask(with: urlRequest) {[weak self] (data, response, error) in //data,_,error
            guard let jsonData = data else {
                completion(.failure(error!))
                return
            }
            if let result = self?.weather(fromJSON: jsonData) {
                completion(result)
            }
        }
        
        task.resume()
    }
    
     func getWeatherSummaryFrom(category : WeatherCategory) -> String {
        switch category {
        case .Clear :
            return "Clear"
        case .PartlyCloudy:
            return "PartlyCloudy"
        case .Cloudy:
            return "Cloudy"
        case .Rain:
            return "Rain"
        case .Wind:
            return "Wind"
        case .Fog:
            return "Fog"
        default:
            return "Thunderstorm"
        }
    }
    
    // param lat , long, date
    
    func weatherUrl(fromLatitude latitude: String, longitude: String, time: String) -> URL {
        
        let baseParam = [
            "key" : apiKey,
            "latitude" : latitude,
            "longitude" : longitude,
            "time": time
        ]
        
        var urlString = baseURLString
       
        urlString += baseParam["key"]! + "/"
        urlString += baseParam["latitude"]! + ","
        urlString += baseParam["longitude"]! + ","
        urlString += baseParam["time"]!
       
        let components = URLComponents(string: urlString)
        return (components?.url!)!
    }
    
    private func weather(fromJSON json: [String: Any]) -> MSWeather? {
        
        guard let weatherCategory = json["icon"] as? String,
            let summaryValue = json["summary"] as? String,
            let temperature = json["temperature"]
            else {
                return nil
        }
        
        let weather = WeatherCategory.getCategory(category: weatherCategory)
        let temperatureStringValue = String(temperature as! Double)
        return MSWeather(category: weather, summary: summaryValue, temperature: temperatureStringValue)
    }
    
    func weather(fromJSON data: Data) -> WeatherResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let weatherDetailJson = jsonDictionary["currently"] as? [String: Any]
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
            
        } catch let error {
            return .failure(error)
        }
    }
}
