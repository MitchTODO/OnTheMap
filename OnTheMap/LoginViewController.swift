//
//  loginViewController.swift
//  OnTheMap
//
//  Created by mitch on 5/9/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController,UITextFieldDelegate {
    
    // TextFields for user credentials
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    // activityIndicator for long request time
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // submit button to login a user
    @IBOutlet weak var loginButton: UIButton!
    
    //show/hide indicator enable/disable loginbutton
    func buttonManagement(command:Bool){
        loginButton.isEnabled = command
        self.activityIndicator.isHidden = command
        
    }
    
    // Button action to POST user input
    @IBAction func logintoOnTheMapApi(_ sender: UIButton) {
            // show indicator / disable login button
            self.buttonManagement(command:false)
            // user input as Opitional from text views
            let username:String = userName.text ?? ""
            let password:String = passWord.text ?? ""
            do {
                // check user input
                try submit(Username: username, Password: password)
                // create and encode a login struct
                let creditials = login(udacity: up(username: username, password: password))
                let jsonData = try JSONEncoder().encode(creditials)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                // execute postRequest login struct as input
                postRequest(url:ontheMapUrl ,jsonRequest:jsonString) {  (output,response,error)  in
                    do {
                            // check response data (output,response,error)
                            try noResponse(data: output,response: response,error: error)
                            let response = response as? HTTPURLResponse
                            try badRequest(httpCode: response!.statusCode,errorToThrow: loginError.invalidConnection)
                            // decode response into Struct
                            try jsonDecoder(data: output!, type: loginResponse.self,takeFive: true) { (loginStruct) in
                                // hold struct as global (SessionData)
                                SessionData = loginStruct
                                // hide indicator / enable button
                                self.buttonManagement(command:true)
                                // performSegue to next view
                                self.performSegue(withIdentifier: "ToTheMap", sender: self)
                            }
                    } catch {
                        // hide indicator / enable button
                        // alert error
                        self.buttonManagement(command:true)
                        error.alert(with: self)
                    }
                }
            } catch loginError.empty{
                // hide indicator / enable button
                // alert error
                self.buttonManagement(command:true)
                loginError.empty.alert(with: self)
                
        } catch {
            // hide indicator / enable button
            // alert error
            self.buttonManagement(command:true)
            loginError.invalidJsonFromUser.alert(with: self)
        }
    }
 
    
// textView delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        passWord.delegate = self
        
    }
    
/*
     INFO: Move view to fit keyboard
     
*/
    
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
        if (passWord.isEditing || userName.isEditing) {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    // MARK: get height of keyboard
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
            return keyboardSize.cgRectValue.height
        }else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            return keyboardSize.cgRectValue.height
        } else {
            print (keyboardSize.cgRectValue.height / 5.0)
            return keyboardSize.cgRectValue.height / 5.0
        }
        
    }
}
