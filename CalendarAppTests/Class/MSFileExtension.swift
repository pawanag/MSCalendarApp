//
//  MSFileExtension.swift
//  CalendarApp
//
//  Created by Pawan on 11/19/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

class MSFileExtension: NSObject {
    func dataFromJSONFile(filePath: String) -> NSData?
    {
        guard let data = openJSONFile(fileName: filePath) else
        {
            return NSData()
        }
        return data
    }
    
    private func openJSONFile(fileName: String) -> NSData?
    {
        guard let filePath = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") else
        {
            return nil
        }
        return NSData(contentsOfFile:filePath)
    }
}
