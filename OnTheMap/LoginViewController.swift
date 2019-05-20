//
//  loginViewController.swift
//  OnTheMap
//
//  Created by mitch on 5/9/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBAction func logintoOnTheMapApi(_ sender: Any) {
        self.activityIndicator.isHidden = false
        var components = URLComponents()
        components.scheme = "https"
        components.host = "onthemap-api.udacity.com"
        components.path = "/v1/session"
        
        let username:String = userName.text ?? ""
        let password:String = passWord.text ?? ""

        let creditials = login(udacity: up(username: username, password: password))
        let MyUrl:URL = components.url!
        
        do {
            let jsonData = try JSONEncoder().encode(creditials)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            postRequest(url:MyUrl ,jsonBody:jsonString){ (output) in
                let range = (5..<output.count)
                let json = output.subdata(in: range)
                let decoder = JSONDecoder()
                self.activityIndicator.isHidden = true
                do {
                    let loginObject = try decoder.decode(loginResponse.self, from:json)
                    if loginObject.account.registered == true {
                        SessionData = loginObject
                        self.performSegue(withIdentifier: "ToTheMap", sender: self)
                    }else{
                       print ("User not registered")
                    }
                } catch {
                    print ("Empty")
                }
            }
        } catch {
            error.alert(with: self)
            print ("Login Failure")
        }
    
    }
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        passWord.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}

