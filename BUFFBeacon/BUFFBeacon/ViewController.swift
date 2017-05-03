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
        writeValueTimer()
        manager = CBCentralManager(delegate: self, queue: nil)
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
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
            self.peripheralBLE = peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_
        central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
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
    
    var headingDataString : String?
    var speed : Double?
    
    var speedArray = [Double?](repeating:nil,count:10)
    var averageSpeedString : String!
    var userSpeed : Double?
    
    func writeValue(){
        if peripheralBLE != nil && characteristicBUFF != nil{
        print("Connected to " + (peripheralBLE?.name)!)
        locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            if(CLLocationManager.headingAvailable() && CLLocationManager.locationServicesEnabled()){
                locationManager.headingFilter = 1
                locationManager.startUpdatingHeading()
                locationManager.startUpdatingLocation()
                //if speedArray[9] != nil {
                    //let averageSpeed = determineAverageSpeed(tempSpeedArray: speedArray)
                    //averageSpeedString = String(averageSpeed)
                    if(headingDataString != nil && userSpeed != nil){
                        let finalDataString :String?
                        finalDataString = headingDataString! + "_" + String(describing: userSpeed) + "\n"
                        self.peripheralBLE?.writeValue((finalDataString?.data(using: String.Encoding.utf8)!)!, for: characteristicBUFF!, type: CBCharacteristicWriteType.withoutResponse)
                    }
                    
                //}
            }
        }
    }
    func locationUpdate(){
        locationManager.startUpdatingLocation()
    }
    
    
    func determineAverageSpeed(tempSpeedArray : [Double?]) -> Double{
        var count = 0.0
        var totalToAverage = 0.0
        
        for i in 0...tempSpeedArray.count-1{
            if tempSpeedArray[i]! < 7.0 && tempSpeedArray[i]! >= 0 {
                totalToAverage += tempSpeedArray[i]!
                count += 1
            }
        }
        speed = totalToAverage/count
        print("Average Speed : " + String(describing: speed))
        return speed!
    }
    
    
    
    //Heading Update
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            headingDataString = String(newHeading.magneticHeading)
            print("didUpdateHeading" + headingDataString!)
        
    }
    
    //Location Update
    var index = 0
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation : CLLocation = locations[0] as CLLocation!
        if userLocation.timestamp .timeIntervalSinceNow > -10.0 {
            userSpeed = Double(userLocation.speed)
            if index < 10 {
                print("didUpdateLocation array not full" + String(index))
                speedArray[index] = userSpeed
                index += 1
            } else{
                var i = 1
                while i<10 {
                    speedArray[i-1] = speedArray[i]
                    if i == 9 {
                        speedArray[i] = userSpeed
                    }
                    i += 1
                }
                print("didUpdateLocation array full" + String(describing: userSpeed))
            }

        }
        
    }
    
    
    //Timer Functions
    var timer1 = Timer()
    var timer2 = Timer()
    func writeValueTimer(){
        timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.writeValue), userInfo: nil, repeats: true)
    }
    
    func locationUpdateTimer(){
        timer2 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.locationUpdate), userInfo: nil, repeats: true)
    }
}

