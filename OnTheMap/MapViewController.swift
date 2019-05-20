//
//  MapViewController.swift
//  OnTheMap
//
//  Created by mitch on 5/10/19.
//  Copyright © 2019 mitch. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController,UserLocationDelegate,MKMapViewDelegate{
    
    /**hold pins**/
    var annotations = [MKPointAnnotation]()
    var tempPin = [MKAnnotation]()

    
    /**IBOutlets**/
    @IBOutlet weak var OnTheMap: MKMapView!
    @IBOutlet weak var refeshButton: UIBarButtonItem!
    @IBOutlet weak var createPinButton: UIBarButtonItem!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var ListButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var loadPinsOnMapIndicator: UIActivityIndicatorView!
    
    /**IBActions**/
    @IBAction func addLocationToMap(_ sender: Any) {
        
        self.buttonSwitch(Swap: true,ButtonTag: 0,ButtonTitle: "LOGOUT")
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "parse.udacity.com"
        components.path = "/parse/classes/StudentLocation"
        
        let placeName =  tempPin[0].title!
        let mediaUrl = tempPin[0].subtitle!
        let lat = tempPin[0].coordinate.latitude
        let long = tempPin[0].coordinate.longitude
        
        
        let pinData2 = "{\"uniqueKey\": \"2318\", \"firstName\": \"John\", \"lastName\": \"Smith\",\"mapString\": \"\(placeName!)\", \"mediaURL\": \"\(mediaUrl!)\",\"latitude\": \(lat), \"longitude\": \(long)}"

        let MyUrl:URL = components.url!
        do {
            postRequest(url:MyUrl ,jsonBody:pinData2){ (output) in
                let range = (5..<output.count)
                let json = output.subdata(in: range) /* subset response data! */
                do {
                    print(String(data: json, encoding: .utf8)!)
                    
                //} catch {
                //    print(error)
                }
            }
            
        //} catch {
         //   print ("JSON Failure")
        }
        self.tempPin.popLast()
    }
 
    
    @IBAction func logout(_ sender: Any) {
        if self.logOutButton.tag == 0 {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "onthemap-api.udacity.com"
            components.path = "/v1/session"
            let MyUrl:URL = components.url!
            deleteRequest(url: MyUrl){ (output) in
                do {
                    //print(String(data: output, encoding: .utf8)!)
                    self.dismiss(animated: true, completion: nil)
                //} catch {
                 //   print("Cant logout")
                }
            }
            
        }else{
            let lastObjectInAnnotationArray = self.tempPin[0]
            self.OnTheMap.removeAnnotation(lastObjectInAnnotationArray)
            buttonSwitch(Swap: true,ButtonTag: 0,ButtonTitle: "LOGOUT")
            let viewRegion = MKCoordinateRegion(center: lastObjectInAnnotationArray.coordinate, latitudinalMeters: 4000000, longitudinalMeters: 4000000)
            OnTheMap.setRegion(viewRegion, animated: false)
            self.tempPin.popLast()
        }
    }
    
    @IBAction func refesh(_ sender: Any) {
        self.loadPinsOnMapIndicator.isHidden = false
        var components = URLComponents()
        components.scheme = "https"
        components.host = "parse.udacity.com"
        components.path = "/parse/classes/StudentLocation"
        let MyUrl:URL = components.url!
        self.OnTheMap.removeAnnotations(self.annotations)
        self.annotations.removeAll()
        studentLocations!.results.removeAll()
        getRequest(url: MyUrl,jsonBody: ""){ (output) in
            let decoder = JSONDecoder()
            do {
                studentLocations = try decoder.decode(pinLocation.self, from:output)
                for pin in studentLocations!.results{
                    let createPin = MKPointAnnotation()
                    createPin.title = pin.mapString
                    createPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude ?? 0.0000, longitude:pin.longitude ?? 0.0000)
                    self.annotations.append(createPin)
                }
                self.loadPinsOnMapIndicator.isHidden = true
                self.OnTheMap.addAnnotations(self.annotations)
            } catch {
                print(error)
            }
        }
        
    }
    
    /**Classs functions**/
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let pin = view.annotation as! MKPointAnnotation
        let placeName = pin.title
        let placeInfo = pin.subtitle

        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: {(action: UIAlertAction!) in
            guard let url = URL(string: placeInfo!) else { return }
            UIApplication.shared.open(url)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction!) in
            print ("Cancel")
        }))
        present(ac, animated: true)
    }
    
   private func buttonSwitch(Swap:Bool,ButtonTag:Int,ButtonTitle:String) -> Void {
        refeshButton.isEnabled = Swap
        createPinButton.isEnabled = Swap
        self.logOutButton.title = ButtonTitle
        self.logOutButton.tag = ButtonTag
        ListButton.isEnabled = Swap
        addLocationButton.isHidden = Swap
    }
    
    func pinUserLocation(location:CLLocation,userFriendlyName:String,userUrl:String) {
        long = location.coordinate.longitude
        lat = location.coordinate.latitude
        freindlyName = userFriendlyName
        Url = userUrl
      
        let coordinate = location.coordinate
        let createPin = MKPointAnnotation()
        createPin.title = userFriendlyName
        createPin.subtitle = Url
        createPin.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude , longitude:coordinate.longitude)
        OnTheMap.addAnnotation(createPin)
        self.tempPin.append(createPin)
        let viewRegion = MKCoordinateRegion(center: createPin.coordinate, latitudinalMeters: 1400, longitudinalMeters: 1400)
        OnTheMap.setRegion(viewRegion, animated: false)
        buttonSwitch(Swap: false,ButtonTag: 1,ButtonTitle: "Cancel")
    }

/**override functions **/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToAddUserLocation" {
            let vc : AddPinViewController = segue.destination as! AddPinViewController
            vc.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        OnTheMap.delegate = self
        var components = URLComponents()
        components.scheme = "https"
        components.host = "parse.udacity.com"
        components.path = "/parse/classes/StudentLocation"
        let MyUrl:URL = components.url!
        self.loadPinsOnMapIndicator.isHidden = false
        getRequest(url: MyUrl, jsonBody: ""){ (output) in
            let decoder = JSONDecoder()
            do {
                studentLocations = try decoder.decode(pinLocation.self, from:output)
                for pin in studentLocations!.results{
                    if pin.mapString != nil || pin.mediaURL != nil{ // dont add pins that are empty 
                        let createPin = MKPointAnnotation()
                        createPin.title = pin.mapString
                        createPin.subtitle = pin.mediaURL
                        createPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude!, longitude:pin.longitude!)
                        self.annotations.append(createPin)
                    }
                }
                self.OnTheMap.addAnnotations(self.annotations)
                self.loadPinsOnMapIndicator.isHidden = true
            } catch {
                print(error)
            }
        }
    }
}
