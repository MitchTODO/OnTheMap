//
//  requestHandler.swift
//  OnTheMap
//
//  Created by mitch on 5/9/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import Foundation
import UIKit

// API KEY
let parseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"


// Session Data
var SessionData:loginResponse? = nil

//Student Pin objects
var studentLocations:pinLocation? = nil

/*
 MARK: login Struct
 INFO: used to encode user logininfo into JSON
*/

struct login : Codable {
    let udacity : up
}

struct up : Codable {
    let username : String
    let password : String
}

/*
 MARK: login response Struct
 INFO: used to decode response from login
*/

struct loginResponse: Codable {
    let account: Account
    let session: Session
}
struct Account: Codable {
    let registered: Bool
    let key: String
}
struct Session: Codable {
    let id, expiration: String
}

/*
 MARK: pin Struct
 INFO: used to decode get request data
*/

struct pinLocation: Codable {
    var results: [Result]
}

struct Result: Codable {
    let objectID, uniqueKey, firstName, lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude, longitude: Double?
    let createdAt, updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case objectID = "objectId"
        case uniqueKey, firstName, lastName, mapString, mediaURL, latitude, longitude, createdAt, updatedAt
    }
}

/*
 MARK: jsonDecoder
 INFO: will decode data into a struct
 NOTE: also removes first five symbols
*/

func jsonDecoder<T : Codable>(data:Data,type:T.Type,takeFive:Bool, completionHandler:@escaping (_ details: T) -> Void)throws  {
    var copyData = data
    if takeFive == true{
    let range = (5..<data.count)
    copyData = copyData.subdata(in: range)
    }
    let decoder = JSONDecoder()
    do {
         let jsonEncode = try decoder.decode(type, from:copyData)
         completionHandler(jsonEncode)
    } catch {
        throw loginError.invalidJson
    }
}


/*
 MARK: Get Request function
 input: url
 output: Optional data,response,error
 NOTE: API keys are placed within http headers
*/
public func getRequest(url:URL,completionBlock:  @escaping  (Data?,URLResponse?,Error?)  -> Void) -> Void{
    var request = URLRequest(url:url,timeoutInterval: 5.0)
    request.addValue(parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(restApiKey,forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
        DispatchQueue.main.async  {
            completionBlock(data,response ,error)
        }
    }
    task.resume()
}


/*
 MARK: Post Request function
 input: url,jsonPayload
 output: Optional data,response,error
 */
public func postRequest(url:URL,jsonRequest:String,completionBlock:  @escaping  (Data?,URLResponse?,Error?)  -> Void) -> Void{
    var request = URLRequest(url:url,timeoutInterval: 5.0)
    request.httpMethod = "POST"
    request.addValue(parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(restApiKey,forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonRequest.data(using: .utf8)
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
            DispatchQueue.main.async  {
                completionBlock(data,response ,error)
            }
    }
    task.resume()
}


/*
 MARK: Delete Request function
 input: url
 output: Optional data,response,error
 */
public func deleteRequest(url:URL,completionBlock: @escaping (Data?,URLResponse?,Error?) -> Void) -> Void{
    var request = URLRequest(url:url,timeoutInterval: 5.0)
    request.httpMethod = "DELETE"
    request.setValue(SessionData?.session.id, forHTTPHeaderField: "X-XSRF-TOKEN")
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
        DispatchQueue.main.async {
            completionBlock(data,response,error)
        }
    }
    task.resume()
}
