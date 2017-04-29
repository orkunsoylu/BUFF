//
//  ViewController.swift
//  BUFFBeacon
//
//  Created by Orkun Soylu on 30/03/2017.
//  Copyright © 2017 Orkun Soylu. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,CLLocationManagerDelegate{
    @IBOutlet weak var button : UIButton!
    
    fileprivate var manager: CBCentralManager?
    fileprivate var peripheralBLE: CBPeripheral?
    
    var serviceUUID = CBUUID(string: "0000FFE3-0000-1000-8000-00805F9B34FB")
    var characteristicUUID = CBUUID(string: "0000FFE1-0000-1000-8000-00805F9B34FB")
    
    var characteristicBUFF : CBCharacteristic?
    
    var locationManager = CLLocationManager()
    var headingValue : Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)

    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    
    
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber) {
        if (peripheral.name == "BUFFBeacon" && (self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
            print(peripheral.name!)
            self.peripheralBLE = peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_
        central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        print("conn")
        self.peripheralBLE?.delegate = self
        peripheral.discoverServices([serviceUUID])
        
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics(
                    [characteristicUUID],
                    for: thisService
                )
                
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == characteristicUUID  {
                self.peripheralBLE?.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
                characteristicBUFF = thisCharacteristic
            }
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    @IBAction func writeValue(_ sender :UIButton){
        print("pressed")
        if peripheralBLE != nil {
            if characteristicBUFF != nil{
                locationManager.delegate = self as CLLocationManagerDelegate
                if(CLLocationManager.headingAvailable()){
                    locationManager.headingFilter = 1
                    locationManager.startUpdatingHeading()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
                    let headingDataString = String(newHeading.magneticHeading)
                    self.peripheralBLE?.writeValue(headingDataString.data(using: String.Encoding.utf8)!, for: characteristicBUFF!, type: CBCharacteristicWriteType.withoutResponse)
        
            }
    
//    //Bluetooth Methods
//    
//    var data : NSDictionary?
//    
//    
//    
//    
//    func setRegion(majorValue : Double,minorValue : Double){
//        self.region = CLBeaconRegion(proximityUUID: UUID.init(uuidString: "E2538291-9359-9384-D58D-5020F77905CB")!, major: CLBeaconMajorValue(majorValue), minor: CLBeaconMinorValue(minorValue), identifier: "keh")
//        self.data = self.region?.peripheralData(withMeasuredPower: nil)
//        self.manager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
//
//    }
//    
//    //-------------------------
//    
//    //Distance and Heading Methods
//    
//    var locationManager = CLLocationManager()
//    
//    var finalDistanceValue : Double?
//    
//    var initialLocation : CLLocation? = nil
//
//    var headingValue : Double? = nil
//
//    func determineMyCurrentLocation() {
//        locationManager.delegate = self as CLLocationManagerDelegate
//        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        
//        if (CLLocationManager.locationServicesEnabled() && CLLocationManager.headingAvailable()){
//            locationManager.startUpdatingLocation()
//            locationManager.headingFilter = 1
//            locationManager.startUpdatingHeading()
//        }
//        
//    }
//    
//    //Heading
//    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//            headingValue = 360 + newHeading.magneticHeading
//        
//            label.text = label.text! + "finalHeadingValue:"
//            label.text = label.text! + String(describing: headingValue!)
//            label.text = label.text! + "\n"
//        
//            print("finalHeadingValue:")
//            print(headingValue ?? "default")
//    }
//    
//    
//    //Distance
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation : CLLocation = locations[0] as CLLocation!
//        
//        if(initialLocation == nil){
//            initialLocation=userLocation
//        } else{
//            finalDistanceValue = userLocation.distance(from: initialLocation!) * 1000
//            if(finalDistanceValue != nil && headingValue != nil){
//                setRegion(majorValue: finalDistanceValue!, minorValue: headingValue!)
//            }
//            label.text = label.text! + "finalDistanceValue:"
//            label.text = label.text! + String(describing: finalDistanceValue!)
//            label.text = label.text! + "\n"
//            
//            print("finalDistanceValue:")
//            print(finalDistanceValue ?? "default")
//
//        }
//    }
}

