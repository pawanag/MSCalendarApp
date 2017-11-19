//
//  MSMockConnectionRegistrar.swift
//  CalendarApp
//
//  Created by Pawan on 11/19/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
@testable import CalendarApp
class MSMockConnectionRegistrar: NetworkRegistrar {

    enum MSJSONResponse: Int {
        case fetchWeatherSuccess = 0
        case fetchWeatherError = 1
    }
    
    var responseJSON: MSJSONResponse = .fetchWeatherSuccess
    
    func initRequest(_ request: URLRequest, withSuccess successhandler: @escaping successHandler, withFailure failurehandler:@escaping failureHandler ) -> Void {
        
        let response  = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = MSFileExtension().dataFromJSONFile(filePath:resonseJSONFILE())
        if data != nil {
            do {
                
                try successhandler(data as Data?, response)
            }
            catch {
                
            }
        }
    }
    
    func resonseJSONFILE() -> String {
        switch responseJSON {
        case .fetchWeatherSuccess: return "fetchWeatherSuccess"
        case .fetchWeatherError: return "fetchWeatherError"
        }
    }
}
