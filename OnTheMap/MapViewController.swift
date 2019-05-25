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
    //@IBOutlet weak var ListButton: UIBarButtonItem!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var loadPinsOnMapIndicator: UIActivityIndicatorView!
    
    /**IBActions**/
    // POST request with new pin data
    @IBAction func addLocationToMap(_ sender: Any) {
        self.buttonSwitch(Swap: true,ButtonTag: 0,ButtonTitle: "LOGOUT")
        do {
            // get data from tempPin
            let placeName =  tempPin[0].title ?? ""
            let mediaUrl = tempPin[0].subtitle ?? ""
            let lat = tempPin[0].coordinate.latitude
            let long = tempPin[0].coordinate.longitude
            // check values of pin
            try checktempPin(placeName: placeName, mediaUrl: mediaUrl , lat: lat, long: long)
            
            let DataOut = "{\"uniqueKey\": \"2318\", \"firstName\": \"John\", \"lastName\": \"Smith\",\"mapString\": \"\(placeName!)\", \"mediaURL\": \"\(mediaUrl!)\",\"latitude\": \(lat), \"longitude\": \(long)}"
            // send POST of newly created pin
            postRequest(url:ontheMapUrlLocations ,jsonRequest:DataOut) { (output,response,error) in
                do{
                    // check response
                    try noResponse(data: output, response: response, error: error)
                    let response = response as? HTTPURLResponse
                    try badRequest(httpCode: response!.statusCode, errorToThrow: pinError.postRequestFailed)
                    // alert pin was successfully added
                    let alertController = UIAlertController(title: nil, message: "Location added successfully", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.refesh(1)
                }catch{
                    error.alert(with: self)
                }
            }
            // remove temp pin data
            self.tempPin.removeAll()
        }catch{
            error.alert(with: self)
        }
    }
 
    // delete request to end user session or cancel post request to create a pin
    // NOTE: use button.tag to ID wether to end session to cancel
    @IBAction func logout(_ sender: Any) {
        if self.logOutButton.tag == 0 {
            deleteRequest(url: ontheMapUrl){ (output,response,error) in
                do {
                    // check response and alert user if fails
                    try noResponse(data: output, response: response, error: error)
                    let response = response as? HTTPURLResponse
                    try badRequest(httpCode: response!.statusCode,errorToThrow: loginError.invalidConnection)
                    self.dismiss(animated: true, completion: nil)
                } catch {
                    error.alert(with: self)
                }
            }
            
        }else{
            //remove last add Annotation
            let lastObjectInAnnotationArray = self.tempPin[0]
            self.OnTheMap.removeAnnotation(lastObjectInAnnotationArray)
            // zoom out of map
            buttonSwitch(Swap: true,ButtonTag: 0,ButtonTitle: "LOGOUT")
            let viewRegion = MKCoordinateRegion(center: lastObjectInAnnotationArray.coordinate, latitudinalMeters: 4000000, longitudinalMeters: 4000000)
            OnTheMap.setRegion(viewRegion, animated: false)
            // remove annotaions
            self.tempPin.removeAll()
        }
    }
    
    // refesh map pins
    @IBAction func refesh(_ sender: Any) {
        // remove all annotations(Pins) on map
        self.OnTheMap.removeAnnotations(self.annotations)
        self.annotations.removeAll()
        // remove all studentLocation objects
        studentLocations?.results.removeAll()
        
        // execute get Pins for studentLocations
        self.getPins()
        
        
    }
    
    
    
    // Get request to repopulates pin on map
    private func getPins() {
        self.loadPinsOnMapIndicator.isHidden = false
        getRequest(url: ontheMapUrlLocationsWithQuery){ (output,response,error) in
            do {
                // check responses
                try noResponse(data: output, response: response, error: error)
                let response = response as? HTTPURLResponse
                try badRequest(httpCode: response!.statusCode,errorToThrow: pinError.getRequestFailed)
                // decode data into pinLocation struct
                try jsonDecoder(data: output!, type: pinLocation.self, takeFive: false) {
                    (decodedPins) in
                    // set global studentLocation 
                    studentLocations = decodedPins
                    // create annotation for each pin object
                    // append each annotation to a array
                    for pin in studentLocations!.results{
                        if pin.mapString != nil || pin.mediaURL != nil{ // dont add pins that are empty
                            let createPin = MKPointAnnotation()
                            createPin.title = pin.mapString
                            createPin.subtitle = pin.mediaURL
                            createPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude!, longitude:pin.longitude!)
                            self.annotations.append(createPin)
                        }
                    }
                    // add array of annotations to MapView
                    self.OnTheMap.addAnnotations(self.annotations)
                    self.loadPinsOnMapIndicator.isHidden = true
                }
            } catch {
                error.alert(with: self)
                self.loadPinsOnMapIndicator.isHidden = true
            }
        }
    }
    
    // setup Annotations on MapView
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
    
    // Handles pin taps / opens url in safari
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
        }))
        present(ac, animated: true)
    }
    
    // handles button switch
   private func buttonSwitch(Swap:Bool,ButtonTag:Int,ButtonTitle:String) -> Void {
        refeshButton.isEnabled = Swap
        createPinButton.isEnabled = Swap
        self.logOutButton.title = ButtonTitle
        self.logOutButton.tag = ButtonTag
        //ListButton.isEnabled = Swap
        addLocationButton.isHidden = Swap
    }
    
    func pinUserLocation(location:CLLocation,userFriendlyName:String,userUrl:String) {
        // create a new pin
        let coordinate = location.coordinate
        let createPin = MKPointAnnotation()
        createPin.title = userFriendlyName
        createPin.subtitle = userUrl
        createPin.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude , longitude:coordinate.longitude)
        // display new pin on map
        OnTheMap.addAnnotation(createPin)
        // append pin to tempPin array
        self.tempPin.append(createPin)
        // adjust the region map
        let viewRegion = MKCoordinateRegion(center: createPin.coordinate, latitudinalMeters: 1400, longitudinalMeters: 1400)
        OnTheMap.setRegion(viewRegion, animated: false)
        
        buttonSwitch(Swap: false,ButtonTag: 1,ButtonTitle: "Cancel")
    }

    /**override functions **/
    // delegate handler for Add pin
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToAddUserLocation" {
            let vc : AddPinViewController = segue.destination as! AddPinViewController
            vc.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        OnTheMap.delegate = self
        self.getPins()
    }
}
