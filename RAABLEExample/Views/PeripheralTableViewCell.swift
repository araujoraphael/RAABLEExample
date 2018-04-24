//
//  PeripheralTableViewCell.swift
//  RAABLEExample
//
//  Created by Raphael Araújo on 2018-04-22.
//  Copyright © 2018 Raphael Araújo. All rights reserved.
//

import UIKit
import CoreBluetooth
class PeripheralTableViewCell: UITableViewCell {
    var peripheral: CBPeripheral? {
        didSet {
            self.layoutSubviews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.text = peripheral?.name
        self.detailTextLabel?.text = peripheral?.state == .connected ? "Connected" : "Tap to connect"
    }

}
