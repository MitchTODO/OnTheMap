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

class AddPinViewController: UIViewController,UITextFieldDelegate {
    
    var delegate : UserLocationDelegate?
    lazy var geocoder = CLGeocoder()
    
    @IBOutlet weak var locationTextFeild: UITextField!
    @IBOutlet weak var urlTextFeild: UITextField!
    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func geocode(_ sender: UIButton) {
        // Geocode Address String
        let pinlocation = locationTextFeild.text ?? ""
        let pinUrl = urlTextFeild.text ?? ""
        do {
            try noPinData(userLocation: pinlocation, userUrl: pinUrl )
            geocoder.geocodeAddressString(pinlocation) { (placemarks, error) in
                    // Use sepreate function to handle errors and delegate
                    self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }catch{
            error.alert(with: self)
        }
    }
    
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?){
        var location: CLLocation?
        do {
            try checkPinLocation(placemark: placemarks?.first?.country,error:error)
            location = placemarks?.first?.location
            delegate?.pinUserLocation(location: location!,userFriendlyName: locationTextFeild.text!,userUrl: urlTextFeild.text!)
            dismiss(animated: true, completion: nil)
        }catch {
            error.alert(with: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextFeild.delegate = self
        urlTextFeild.delegate = self
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: default view without keyboard
    @objc func keyboardWillHide(_ notification:Notification) {
        self.view.frame.origin.y = 0
    }
    
    // MARK: moved view with keyboard
    @objc func keyboardWillShow(_ notification:Notification) {
        if (urlTextFeild.isEditing) {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // MARK: get height of keyboard
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            return keyboardSize.cgRectValue.height / 2.0
        }else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            return keyboardSize.cgRectValue.height / 2.0
        } else {
            return keyboardSize.cgRectValue.height / 5.0
        }
        
    }
    
    
}
