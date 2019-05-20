//
//  requestHandler.swift
//  OnTheMap
//
//  Created by mitch on 5/9/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import Foundation
import UIKit

let parseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
let restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"



// Session Data
var SessionData:loginResponse? = nil

//Pin objects
var studentLocations:pinLocation? = nil

// Used for user pin data

var long: Double?
var lat: Double?
var freindlyName: String?
var Url: String?


struct login : Codable {
    let udacity : up
}

struct up : Codable {
    let username : String
    let password : String
}

// Used at signin response
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

// Used for pinLocation
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

func addQueryToUrlComponents(defaulUrlComponent:URLComponents, queryName:String,queryValue:String) -> URLComponents{
    var changedUrl = defaulUrlComponent
    changedUrl.queryItems = [URLQueryItem(name: queryName, value: queryValue)]
    return changedUrl
}



/*********GET REQUEST*****************/
func getRequest(url:URL,jsonBody:String,completionBlock: @escaping (Data) -> Void)  -> Void {
    var request = URLRequest(url: url)
    request.addValue(parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(restApiKey,forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    if jsonBody != ""{
        request.httpBody = jsonBody.data(using: .utf8)
    }
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
        DispatchQueue.main.async {
            if let error = error {
                print (error)
            } else {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 { // show JSON if
                        completionBlock(data!)
                    }else{
                        
                        print (response)
                    }
                }
            }
        }
    }
    task.resume()
}



/*********POST REQUEST*****************/
public func postRequest(url:URL,jsonBody:String,completionBlock: @escaping (Data) -> Void) -> Void{
    //do {
    var request = URLRequest(url:url)
    request.httpMethod = "POST"
    request.addValue(parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(restApiKey,forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonBody.data(using: .utf8)
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
            DispatchQueue.main.async {
            if let error = error {
                completionBlock(data!)
            } else {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 { // show JSON if
                        completionBlock(data!)
                    }else{
                        completionBlock(data!)
                    }
                }
            }
        }
    }
    task.resume()
    //}catch{
        //throw print (error)
    //}
}


/*********DELETE REQUEST*****************/
public func deleteRequest(url:URL,completionBlock: @escaping (Data) -> Void) -> Void{
    var request = URLRequest(url:url)
    request.httpMethod = "DELETE"
    request.setValue(SessionData?.session.id, forHTTPHeaderField: "X-XSRF-TOKEN")
    let session = URLSession.shared
    let task = session.dataTask(with: request) {data,response,error in
        DispatchQueue.main.async {
            if let error = error {
                print (error)
            } else {
                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 { // show JSON if
                        completionBlock(data!)
                    }else{
                        print (response)
                    }
                }
            }
        }
    }
    task.resume()
}
