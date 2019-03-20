//
//  Device.swift
//  BLESample
//
//  Created by yusuke saso on 2019/03/21.
//  Copyright © 2019 yusuke saso. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

class Device {
    var peripheral: CBPeripheral?
    var advertisementData: [String: Any]?
    var rssi: NSNumber?
    
    var name: String {
        get {
            return advertisementData?["kCBAdvDataLocalName"] as? String ?? "no name"
        }
    }
}
