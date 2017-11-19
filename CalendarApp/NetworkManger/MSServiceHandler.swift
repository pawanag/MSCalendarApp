//
//  MSServiceHandler.swift
//  CalendarApp
//
//  Created by Pawan on 11/19/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

//
typealias CHandler = (_ error: Error? , _ responseDictionary: Any?) -> Void

class MSServiceHandler: NSObject {
    
    typealias completionHandler = (_ error: Error? , _ responseDictionary: Any?) throws -> Void
    
    let connectHandler: NetworkRegistrar
    
    init( connectHandler: NetworkRegistrar = MSNetworkRegistrar()) {
        self.connectHandler = connectHandler
    }
    
    func fetchWeatherInfo(url : URL, handler : @escaping CHandler) {
        
        var urlReq:URLRequest = URLRequest(url: url)
        urlReq.httpMethod = "GET"
        loadRequest(urlReq, handler: { [weak self](error, responseDictionary) throws -> Void in
            guard let responseDictionary = responseDictionary  else {
                handler(error,nil)
                return
            }
            handler(nil,responseDictionary)
        })

    }
   
    func loadRequest(_ request: URLRequest, handler: @escaping completionHandler) {
        connectHandler.initRequest(request, withSuccess: { (data, response) in
            if let data = data {
                var object : Any?
                object = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments, JSONSerialization.ReadingOptions.mutableContainers])
                DispatchQueue.main.async {
                    do {
                        try handler(nil,object)
                    }
                    catch {
                        assertionFailure("couldn't")
                    }
                }
            }
        }) { (data, response, error) in
            do {
                try handler(error,nil)
            }
            catch {
                assertionFailure("couldn't")
            }
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(
            .useCredential,
            URLCredential(trust: challenge.protectionSpace.serverTrust!)
        )
    }
}

