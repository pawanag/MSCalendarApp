//
//  MSServiceHandler.swift
//  CalendarApp
//
//  Created by Pawan on 11/19/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

//
typealias CompletionHandler = (_ error: Error? , _ responseDictionary: Any?) -> Void

class MSServiceHandler: NSObject {
    
    typealias completionHandler = (_ error: Error? , _ responseDictionary: Any?) throws -> Void
    
    let connectHandler: NetworkRegistrar
    
    init( connectHandler: NetworkRegistrar = MSNetworkRegistrar()) {
        self.connectHandler = connectHandler
    }
    
    /** Method to fetch Weather Info based on the URL provided by the Manager class
     @Param url : URL which Manager class needs to provide
     */
    func fetchWeatherInfo(url : URL, handler : @escaping CompletionHandler) {
        
        var urlReq:URLRequest = URLRequest(url: url)
        // Defines the Type of Request , In our case it is a get Request
        urlReq.httpMethod = "GET"
        loadRequest(urlReq, handler: { (error, responseDictionary) throws -> Void in
            guard let responseDictionary = responseDictionary  else {
                handler(error,nil)
                return
            }
            handler(nil,responseDictionary)
        })

    }
   
    /** Method to fetch Weather Info based on the Request Provide
     @Param URLRequest : URLRequest
     */
    
    func loadRequest(_ request: URLRequest, handler: @escaping completionHandler) {
        connectHandler.initRequest(request, withSuccess: { (data, response) in
            if let data = data {
                var object : Any?
                object = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments, JSONSerialization.ReadingOptions.mutableContainers])
                // Try catch block as the handler Throws an exception
                    do {
                        try handler(nil,object)
                    }
                    catch {
                        print("couldn't fetch the Info")
                    }
            }
        }) { (data, response, error) in
             // Try catch block as the handler Throws an exception 
            do {
                try handler(error,nil)
            }
            catch {
                print("couldn't fetch the Info")
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

