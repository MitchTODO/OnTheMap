//
//  endPoints.swift
//  OnTheMap
//
//  Created by mitch on 5/9/19.
//  Copyright © 2019 mitch. All rights reserved.
//
// MARK: contains API endpoints for request

import Foundation
import UIKit


/*
 MARK: parseEndpoint
 struct to hold strings for url
 use strings to build out url
*/

struct parseEndpoint {
    static let scheme = "https"
    static let host = "parse.udacity.com"
    static let path = "/parse/classes/StudentLocation"
}

var parseComponents:URLComponents{
    var components = URLComponents()
    components.scheme = parseEndpoint.scheme
    components.host = parseEndpoint.host
    components.path = parseEndpoint.path
    return components
}

let parseUrl:URL = parseComponents.url!


/*
 MARK: OnTheMapEndpoint
 struct to hold strings for url
 use strings to build out url
*/

struct onTheMapEndpoint {
    static let scheme = "https"
    static let host = "onthemap-api.udacity.com"
    static let path = "/v1/session"
}

var onthemapComponents:URLComponents{
    var components = URLComponents()
    components.scheme = onTheMapEndpoint.scheme
    components.host = onTheMapEndpoint.host
    components.path = onTheMapEndpoint.path
    return components
}

let ontheMapUrl:URL = onthemapComponents.url!
