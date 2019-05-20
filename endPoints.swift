//
//  endPoints.swift
//  OnTheMap
//
//  Created by mitch on 5/9/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import Foundation
import UIKit

/********************** Endpoints **********************/

struct parseEndpoint {
    static let scheme = "https"
    static let host = "parse.udacity.com"
    static let path = "/parse/classes"
    struct pathOptions{
        static let studentLocation = "StudentLocation"
    }
}


struct onTheMapEndpoint {
    static let scheme = "https"
    static let host = "onthemap-api.udacity.com"
    static let path = "/v1"
    struct pathOptions{
        static let users = "users"
        static let session = "session"
    }
}

