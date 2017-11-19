//
//  MSCalendarAPITests.swift
//  CalendarAppTests
//
//  Created by Pawan on 11/19/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import XCTest
@testable import CalendarApp

class MSCalendarAPITests: XCTestCase {
    let registrar: MSMockConnectionRegistrar = MSMockConnectionRegistrar()
    let locationManager = MSMockLocationManager()
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWeatherAPISuccess() {
        registrar.responseJSON = .fetchWeatherSuccess
        let handler = MSServiceHandler(connectHandler: registrar as NetworkRegistrar )
        let manager = MSWeatherManager(webserviceHandler: handler)

        let viewModel = MSCalendarViewModel(manager, locationManager: locationManager)
        viewModel.fetchWeather(info: "12313", location: locationManager.userLocation!) { (weatherResult: WeatherResult) in
            switch weatherResult {
            case let .success(weather):
                let temperatureInDouble = Double(68.71)
                let tempInCelsius = (temperatureInDouble - 32)*(5/9)
                let temperature = String(format: "%.0f", ceil(tempInCelsius*100)/100) + " °C"
                XCTAssert(weather.temperature == temperature,"Fail")
            case .failure(_):
               XCTAssertTrue(false, "Fail")
            }
        }
    }
    
    func testWeatherAPIFail() {
        registrar.responseJSON = .fetchWeatherError
        
        let handler = MSServiceHandler(connectHandler: registrar as NetworkRegistrar )
        let manager = MSWeatherManager(webserviceHandler: handler)
        let viewModel = MSCalendarViewModel(manager, locationManager: locationManager)
        viewModel.fetchWeather(info: "12313", location: locationManager.userLocation!) { (weatherResult: WeatherResult) in
            switch weatherResult {
            case .success(_):
                XCTAssertTrue(false, "Fail")
            case .failure(_):
                XCTAssertTrue(true, "Fail")
            }
        }
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
