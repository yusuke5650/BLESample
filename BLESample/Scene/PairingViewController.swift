//
//  ViewController.swift
//  BLESample
//
//  Created by yusuke saso on 2019/01/26.
//  Copyright © 2019 yusuke saso. All rights reserved.
//

import UIKit
import CoreBluetooth

class PairingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet weak var detailTextView: UITextView! {
        didSet {
            detailTextView.isEditable = false
        }
    }
    @IBOutlet weak var bleStateTextView: UITextView! {
        didSet {
            bleStateTextView.isEditable = false
        }
    }
    
    @IBOutlet weak var scanButton: UIButton!
    
    var devices = [UUID: Device]()
    var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    @IBAction func onClickScan(_ sender: Any) {
        if centralManager.isScanning == false {
            tableView.reloadData()
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            scanButton.setTitle("Stop Scan", for: .normal)
        } else {
            centralManager.stopScan()
            scanButton.setTitle("Start Scan", for: .normal)
        }
    }
}

extension PairingViewController: UITableViewDataSource {
    /// Cellの総数を返す。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
}
extension PairingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier:"MyCell" )
        do {
            var name = ""
            var uuid = ""
            if let firstKey = Array(self.devices.keys).first,
                let device = devices[firstKey] {
                name = device.name
                uuid = device.peripheral?.identifier.uuidString ?? ""
            }
            // Cellに値を設定.
            cell.textLabel!.sizeToFit()
            cell.textLabel!.textColor = UIColor.red
            cell.textLabel!.text = name
            cell.textLabel!.font = UIFont.systemFont(ofSize: 20)
            // Cellに値を設定(下).
            cell.detailTextLabel!.text = uuid.description
            cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 12)
            return cell
        } catch let e {
            print(e)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let firstKey = Array(self.devices.keys).first,
            let device = devices[firstKey] {
            var text = "index: \(indexPath.row)"
            if let peripheral = device.peripheral {
                text += "\nperipheral.uuid: \(peripheral.identifier.uuidString)"
                text += "\nperipheral.name: \(peripheral.name)"
                text += "\nperipheral.services: \(peripheral.services)"
                for service in peripheral.services ?? [CBService]() {
//                    text += "\n \(service.)"
                }
            }
            text += "\nRSSI: \(device.rssi)"
            let kCBAdvDataLocalName = device.name
            text += "\nName: \(kCBAdvDataLocalName)"
            if let data = device.advertisementData {
                for content in data {
                    text += "\n\(content.key): \(content.value)"
                }
            }
            print(device.advertisementData)
            detailTextView.text = text
        } else {
            detailTextView.text = "nothing"
        }
        
        
//        print("pheripheral.name: \(String(describing: peripheral.name))")
//        print("advertisementData:\(advertisementData)")
//        print("RSSI: \(RSSI)")
//        print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)")
//        let uuid = UUID(uuid: peripheral.identifier.uuid)
//        self.uuids.append(uuid)
//        let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String
//
//
//        if let name = kCBAdvDataLocalName {
//            self.names[uuid] = name.description
//        } else {
//            self.names[uuid] = "no name"
//        }
//        self.peripherals[uuid] = peripheral
    }
}
extension PairingViewController: CBCentralManagerDelegate {
    
    /// Central Managerの状態がかわったら呼び出される。
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)")
        var text = ""
        switch central.state {
        case .poweredOff:
            text = "Bluetoothの電源がOff"
        case .poweredOn:
            text = "Bluetoothの電源はOn"
        case .resetting:
            text = "レスティング状態"
        case .unauthorized:
            text = "非認証状態"
        case .unknown:
            text = "不明"
        case .unsupported:
            text = "非対応"
        }
        bleStateTextView.text = text
    }
    
    /// PheripheralのScanが成功したら呼び出される。
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let device = Device()
        device.advertisementData = advertisementData
        device.peripheral = peripheral
        device.rssi = RSSI
        devices[UUID(uuid: peripheral.identifier.uuid)] = device
        
        tableView.reloadData()
    }
}

