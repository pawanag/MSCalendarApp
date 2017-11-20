//
//  MSNetworkRegistrar.swift
//  CalendarApp
//
//  Created by Pawan on 11/19/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import UIKit

typealias successHandler = (_ data: Data?, _ response: URLResponse?) throws -> Void
typealias failureHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) throws -> Void

protocol NetworkRegistrar: class {
    func initRequest(_ request: URLRequest, withSuccess successhandler: @escaping successHandler, withFailure failurehandler:@escaping failureHandler ) -> Void
}

class MSNetworkRegistrar: NSObject, NetworkRegistrar,URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(
            .useCredential,
            URLCredential(trust: challenge.protectionSpace.serverTrust!)
        )
    }
    
    func initRequest(_ request: URLRequest, withSuccess successhandler: @escaping successHandler, withFailure failurehandler:@escaping failureHandler ) -> Void {
        
        let sessionConfig = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { (data, response, error)-> Void in
            if let data = data {
                do {
                    try successhandler(data, response)
                }
                catch {
                    print("Couldn't Fetch Data")
                }
                
            } else {
                do {
                    try failurehandler(nil,nil,error)
                }
                catch {
                    print("Couldn't Fetch Data")
                }
            }
        }
        task.resume()
    }
    
}
