//
//  DeviceListViewController.swift
//  RAABLEExample
//
//  Created by Raphael Araújo on 2018-04-22.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = [CBPeripheral]()
    var verifyAvailablePeripheralsTimer: Timer!

    enum ScanButtonState: Int { case initializingServices = 0, isScanning, doingNothing }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScanButton(state: .initializingServices)
        startBTCentralManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        verifyAvailablePeripheralsTimer.invalidate()
    }
    
    @IBAction func scanPeripherals(sender: UIButton) {
        configureScanButton(state: .isScanning)
        let connectedPeripherals = peripherals.filter { (peripheral) -> Bool in
            peripheral.state == .connected
        }
        
        peripherals.removeAll()
        peripherals.append(contentsOf: connectedPeripherals)
        tableView.reloadData()
        
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        if verifyAvailablePeripheralsTimer == nil {
            verifyAvailablePeripheralsTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(DeviceListViewController.stopScanningForPeripherals), userInfo: nil, repeats: true)
        }
    }
    
    private func configureScanButton(state: ScanButtonState) {
        scanButton.isEnabled = (state == .doingNothing)
        
        if state == .doingNothing {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        
        switch state {
        case .initializingServices:
            scanButton.setTitle("Initializing services ...", for: .normal)
        case .doingNothing:
            scanButton.setTitle("Tap to scan", for: .normal)
        default:
            scanButton.setTitle("Looking for peripherals ...", for: .normal)
        }
    }
}

extension DeviceListViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    private func startBTCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            configureScanButton(state: .doingNothing)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
            self.tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        tableView.reloadData()
        print("did connect with: \(peripheral.name!)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        tableView.reloadData()
        print("did disconnect with: \(peripheral.name!)")
    }
    
    @objc func stopScanningForPeripherals() {
        centralManager.stopScan()
        configureScanButton(state: .doingNothing)
    }
}

extension DeviceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]
        if peripheral.state == .connected {
            centralManager.cancelPeripheralConnection(peripheral)
        } else {
            centralManager.connect(peripheral, options: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DeviceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") as! PeripheralTableViewCell
        cell.peripheral = peripherals[indexPath.row]
        return cell
    }
}
