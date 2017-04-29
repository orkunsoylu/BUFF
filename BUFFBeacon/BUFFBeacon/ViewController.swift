//
//  ViewController.swift
//  BUFFBeacon
//
//  Created by Orkun Soylu on 30/03/2017.
//  Copyright © 2017 Orkun Soylu. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController,CBPeripheralManagerDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var label : UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = ""
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            determineMyCurrentLocation()
        }
        
        
    }
    
    
    //Bluetooth Methods
    var region : CLBeaconRegion?
    var data : NSDictionary?
    var manager = CBPeripheralManager()
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager){
        let advertiseData = data as! [String : AnyObject]
        self.manager.startAdvertising(advertiseData)
    }
    
    func setRegion(majorValue : Double,minorValue : Double){
        self.region = CLBeaconRegion(proximityUUID: UUID.init(uuidString: "E2538291-9359-9384-D58D-5020F77905CB")!, major: CLBeaconMajorValue(majorValue), minor: CLBeaconMinorValue(minorValue), identifier: "keh")
        self.data = self.region?.peripheralData(withMeasuredPower: nil)
        self.manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)

    }
    
    //-------------------------
    
    //Distance and Heading Methods
    
    var locationManager = CLLocationManager()
    
    var finalDistanceValue : Double?
    
    var initialLocation : CLLocation? = nil

    var headingValue : Double? = nil

    func determineMyCurrentLocation() {
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        if (CLLocationManager.locationServicesEnabled() && CLLocationManager.headingAvailable()){
            locationManager.startUpdatingLocation()
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
        
    }
    
    //Heading
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            headingValue = 360 + newHeading.magneticHeading
        
            label.text = label.text! + "finalHeadingValue:"
            label.text = label.text! + String(describing: headingValue!)
            label.text = label.text! + "\n"
        
            print("finalHeadingValue:")
            print(headingValue ?? "default")
    }
    
    
    //Distance
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation!
        
        if(initialLocation == nil){
            initialLocation=userLocation
        } else{
            finalDistanceValue = userLocation.distance(from: initialLocation!) * 1000
            if(finalDistanceValue != nil && headingValue != nil){
                setRegion(majorValue: finalDistanceValue!, minorValue: headingValue!)
            }
            label.text = label.text! + "finalDistanceValue:"
            label.text = label.text! + String(describing: finalDistanceValue!)
            label.text = label.text! + "\n"
            
            print("finalDistanceValue:")
            print(finalDistanceValue ?? "default")

        }
    }
}

