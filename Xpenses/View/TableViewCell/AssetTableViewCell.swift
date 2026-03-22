//
//  AssetTableViewCell.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 26/01/26.
//

import UIKit

class AssetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
 
    func initialize(with asset: Asset) {
        nameLabel.text = asset.name
        valueLabel.text = "₹\(formatWithCommas(asset.latestValue))"
        typeLabel.text = asset.type.capitalized
    }
}
