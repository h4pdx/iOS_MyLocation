//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Ryan Hoover on 8/18/18.
//  Copyright © 2018 fatalerr. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Interface variables
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    // MARK: - Instance variables
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false;
    var lastGeocodingError: Error?
    
    var timer: Timer? // global time-out for geocoding

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: -  Hide navigation bar for main tab
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    // show nav bar again after we leave this view
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        /*
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        */
        //startLocationManager()
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    // MARK: - CLLoactionManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    // MARK: - Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last! // last valid location
        print("didUpdateLocations \(newLocation)")
        // ignore last results if they are too old (cached)
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // ignore horizontal accuracy if it is below 0
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = self.location {
            // how far is new reading from previous reading?
            distance = newLocation.distance(from: location)
        }
        // if this is 1st update, or new location data is more accurate
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil // clear previous errors
            location = newLocation // update location
            // if new location is within desired accuracy, stop looking for new updates
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're Done!")
                stopLocationManager()
                if distance > 0 {
                    // force reverse geocoding for final loc,
                    // even if already performing another geocoding req
                    performingReverseGeocoding = false
                }
            }
            updateLabels()
        
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                // use a closure instead of a delegate to retunr info to caller
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    /*
                    placemarks, error in // list of closure parameters, optionals
                    if let error = error { // upnwrap optional paramater
                        print("*** Reverse Geocoding error: \(error.localizedDescription)")
                        return
                    }
                    if let places = placemarks { // unwrap optional parameter
                        print("*** Found places: \(places)")
                    }
                    */
                    placemarks, error in
                    self.lastGeocodingError = error
                    // can have multiple conditions consolidated into one line!!
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last! //can force unwrap bc of prev conditional
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance < 1 {
            // if new coordinates are not much different, and its been > 10 sec, stop looking
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }
    
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in settings",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Buttons & Labels
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    func updateLabels() {
        if let location = self.location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = "" // message label if coordinates were found
            
            if let placemark = self.placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            //messageLabel.text = "Tap 'Get My Location' to Start"
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    // MARK: - Start & Stop Location Manager
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = "" // street number and name
        if let s = placemark.subThoroughfare {
            line1 += s + " " // append st number
        }
        if let s = placemark.thoroughfare {
            line1 += s // append st number
        }
        var line2 = "" // city, state, zip
        if let s = placemark.locality {
            line2 += s + " " // append city
        }
        if let s = placemark.administrativeArea {
            line2 += s + " " // append state
        }
        if let s = placemark.postalCode {
            line2 += s // append zip
        }
        return line1 + "\n" + line2 // return 4567 main st \n chicao, IL 60606
    }

    // MARK: - Objective-C functions
    // selector statement
    // timeout geocoding if no location has been found yet
    @objc func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            self.lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1, userInfo: nil
            )
            updateLabels()
        }
    }
}
