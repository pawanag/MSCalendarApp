//
//  MSMockLocationManager.swift
//  CalendarApp
//
//  Created by Pawan on 11/19/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit
@testable import CalendarApp

class MSMockLocationManager: MSLocationManager {
    override init() {
        super.init()
        userLocation = MSLocation(latitude: "28.704059", longitude: "77.102490")
    }
}
