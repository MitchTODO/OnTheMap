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
 MARK: OnTheMapEndpoint
 struct to hold strings for url
 use strings to build out url
*/
struct onTheMapEndpoint {
    static let scheme = "https"
    static let host = "onthemap-api.udacity.com"
    static let path = "/v1/session"
    static let pathTolocations = "/v1/StudentLocation"
}

var onthemapComponents:URLComponents{
    var components = URLComponents()
    components.scheme = onTheMapEndpoint.scheme
    components.host = onTheMapEndpoint.host
    components.path = onTheMapEndpoint.path
    return components
}

var onthemapComponentsToLocations:URLComponents{
    var components = URLComponents()
    components.scheme = onTheMapEndpoint.scheme
    components.host = onTheMapEndpoint.host
    components.path = onTheMapEndpoint.pathTolocations
    return components
}

var onthemapComponentsToLocationsQuery:URLComponents{
    var components = URLComponents()
    components.scheme = onTheMapEndpoint.scheme
    components.host = onTheMapEndpoint.host
    components.path = onTheMapEndpoint.pathTolocations
    components.queryItems = [URLQueryItem(name: "limit", value: "100"),URLQueryItem(name:"order", value:"-updatedAt")]
    return components
}


let ontheMapUrl:URL = onthemapComponents.url!
let ontheMapUrlLocations:URL = onthemapComponentsToLocations.url!
let ontheMapUrlLocationsWithQuery:URL = onthemapComponentsToLocationsQuery.url!
