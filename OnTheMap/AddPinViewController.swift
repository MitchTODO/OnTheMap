//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by mitch on 5/14/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit
import CoreLocation

protocol UserLocationDelegate {
    func pinUserLocation(location:CLLocation,userFriendlyName:String,userUrl:String)
}

class AddPinViewController: UIViewController {
    
    var delegate : UserLocationDelegate?
    lazy var geocoder = CLGeocoder()
    
    @IBOutlet weak var locationTextFeild: UITextField!
    @IBOutlet weak var urlTextFeild: UITextField!
    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func geocode(_ sender: UIButton) {
        // Geocode Address String
        let Userlocation = locationTextFeild.text ?? ""
        print (Userlocation)
        if Userlocation != "" {
        geocoder.geocodeAddressString(Userlocation) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }else{
            print ("No Location information")
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
  
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            //locationLabel.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            if let location = location {
                delegate?.pinUserLocation(location: location,userFriendlyName: locationTextFeild.text ?? "",userUrl: urlTextFeild.text ?? "")
                dismiss(animated: true, completion: nil)
            } else {
                print ("No Matching Location Found")
            }
        }
    }
    
}
