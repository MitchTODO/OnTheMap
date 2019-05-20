//
//  errorHandler.swift
//  OnTheMap
//
//  Created by mitch on 5/19/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import Foundation
import UIKit


enum YearError: Error {
    case empty
    case invalidNumber
    case invalidBirthYear
    case invalidYear
}

extension YearError: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .empty: return "You didn't provide anything"
        case .invalidNumber: return "You didn't provide a valid number"
        case .invalidBirthYear: return "You can't be born in the future 🤔"
        case .invalidYear: return "You didn't provide a valid 4 digits year such as 1989"
        }
    }
}
/// Extending error to make it alertable
extension Error {
    
    /// displays alert from source controller
    func alert(with controller: UIViewController) {
        let alertController = UIAlertController(title: "Oops ❗️", message: "\(self)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}
