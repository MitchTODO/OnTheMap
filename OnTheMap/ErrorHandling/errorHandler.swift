//
//  errorHandler.swift
//  OnTheMap
//
//  Created by mitch on 5/19/19.
//  Copyright © 2019 mitch. All rights reserved.
//
//

import Foundation
import UIKit

/*
 MARK: LoginViewController Errors
 INFO: Maps user strings to approprate errors
 NOTE: Some errors are reused between viewControllers
 */

enum loginError: Error {
    case empty
    case invalidJson
    case invalidJsonFromUser
    case invalidAccount
    case invalidServer
    case invalidConnection
}

extension loginError: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty: return "Empty Email or Password"
        case .invalidJsonFromUser: return "Internal Error"
        case .invalidJson: return "Unable to read message from server."
        case .invalidAccount: return "Invalid Email or Password"
        case .invalidServer: return "Server offline"
        case .invalidConnection: return "Unable to connect to server"
        }
    }
}

/*
 MARK: MapViewController, AddPinViewController, TableViewController Errors
 INFO: Maps user strings to approprate errors
 */

enum pinError: Error {
    case empty
    case cantFindLocation
    case majorError
    case notaUrl
    case getRequestFailed
    case postRequestFailed
}

extension pinError: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty: return "Empty Location or URL"
        case .cantFindLocation: return "Unable to find loction"
        case .majorError: return "Error as occurd"
        case .notaUrl: return "Cannot open invalid url"
        case .getRequestFailed: return "Cannot get locations from server"
        case .postRequestFailed: return "Cannot add locations"
        }
    }
}

/*
 MARK: alertErrors
 INFO: allows for error strings to be presented
 NOTE:
 Extending error to make it alertable
 displays alert from source controller
 */

extension Error {
    
    func alert(with controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: "\(self)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}


/*
 MARK: Guard functions
 INFO: checks a instance allowing for errors to be throw
*/

// Checks a httpsStatus code
func badRequest(httpCode:Int, errorToThrow:Error!)throws {
    if httpCode >= 400 && httpCode < 500 {
        throw errorToThrow
    }; if httpCode >= 500 {
        throw loginError.invalidServer
    }
}

// Checks data, response and error is nil
func noResponse( data:Data?,response:URLResponse?,error:Error?) throws {
    guard data != nil else {throw loginError.invalidConnection}
    guard response != nil else {throw loginError.invalidConnection}
    guard error == nil else {throw loginError.invalidConnection}
}

// Check user credentials login within loginviewcontroller
func submit(Username:String,Password:String)throws{
    guard Username != "" else {throw loginError.empty}
    guard Password != "" else {throw loginError.empty}
}

// Check user pin information is not empty within AddPinviewcontroller
func noPinData(userLocation:String?,userUrl:String?) throws {
    guard userLocation != "" else {throw pinError.empty}
    guard userUrl != "" else {throw pinError.empty}
}

// Check user pin location for empty or nil
func checkPinLocation(placemark:String?, error:Error?) throws {
    guard placemark != "" else {throw pinError.cantFindLocation}
    guard error == nil else {throw pinError.cantFindLocation}
}

// final check for placename, url, latitude and longitude
func checktempPin(placeName:String?,mediaUrl:String?,lat:Double?,long:Double?) throws {
    guard placeName != "" || mediaUrl != "" || lat != nil || long != nil else {throw pinError.majorError}
}
