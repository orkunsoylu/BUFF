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
import CoreMotion

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,CLLocationManagerDelegate{

@IBOutlet weak var messageLabel: UITextView!
@IBOutlet weak var currentRSSILabel: UILabel!
@IBOutlet weak var currentSpeedLabel: UILabel!
@IBOutlet weak var currentHeadingLabel: UILabel!
@IBOutlet weak var connectionStatusLabel: UILabel!

fileprivate var manager: CBCentralManager?
fileprivate var peripheralBLE: CBPeripheral?

var motionManager = CMMotionActivityManager()
var motionActivity : CMMotionActivity?
var serviceUUID = CBUUID(string: "0000FFE3-0000-1000-8000-00805F9B34FB")
var characteristicUUID = CBUUID(string: "0000FFE1-0000-1000-8000-00805F9B34FB")

var characteristicBUFF : CBCharacteristic?

var locationManager = CLLocationManager()
var headingValue : Double? = nil

var timer1 = Timer()

var headingDataString : String?

var speedArray = [Double?](repeating:nil,count:10)
var averageSpeedString : String!
var userSpeed : Double!
var isStopped : String?
    
var rssi : Double?

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
        connectionStatusLabel.text = "Searching for Device..."
        
    } else {
        connectionStatusLabel.text = "Turn On Bluetooth"
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
            connectionStatusLabel.text = peripheralBLE?.name!
            peripheralBLE?.setNotifyValue(true, for: thisCharacteristic)
        }
    }
}

func centralManager(
    _ central: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral,
    error: Error?) {
    central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    connectionStatusLabel.text = "Searching for Device..."
}


func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    if let dataBytes = characteristic.value {
        let backToString = String(data: dataBytes, encoding: String.Encoding.utf8) as String!
        print(dataBytes)
        print(backToString!)
        messageLabel.text = backToString!
    }
}


func writeValue(){
    if peripheralBLE != nil && characteristicBUFF != nil{
        peripheralBLE?.readRSSI()
        if rssi != nil{
            if rssi! < -90.0 {
                currentRSSILabel.text = "Too far away from BUFF"
            }
        }
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if(CLLocationManager.headingAvailable() && CLLocationManager.locationServicesEnabled() && CMMotionActivityManager.isActivityAvailable()){
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
            locationManager.startUpdatingLocation()
            motionManager.startActivityUpdates(to: OperationQueue.init(), withHandler: { activityData
                in
                if activityData!.stationary == true {
                    self.isStopped = "stopped"
                } else {
                    self.isStopped = "moving"
                }
                
            })
        }
        if(headingDataString != nil && userSpeed != nil && isStopped != nil){
            currentHeadingLabel.text = headingDataString!
            if userSpeed >= 0.0 && userSpeed <= 7.0{
                currentSpeedLabel.text = String(userSpeed)
            }
            
            let finalDataString :String?
            finalDataString = headingDataString! + "_" + String(describing: userSpeed!) + "&" + isStopped! + "%"
            self.peripheralBLE?.writeValue((finalDataString?.data(using: String.Encoding.utf8)!)!, for: characteristicBUFF!, type: CBCharacteristicWriteType.withoutResponse)
            
        }
        
        
    }
}

func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    currentRSSILabel.text = String(describing:RSSI)
    rssi = RSSI as? Double
    
}
    
func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let roundedHeading = Double(round(100*newHeading.magneticHeading)/100)
    headingDataString = String(roundedHeading)
    
    
}



func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let userLocation : CLLocation = locations.last as CLLocation!
    let locationTime = userLocation.timestamp
    if locationTime.timeIntervalSinceNow < 2.0{
        userSpeed = Double(round(100*userLocation.speed)/100)
    }
}




func writeValueTimer(){
    timer1 = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.writeValue), userInfo: nil, repeats: true)
}

}
