//
//  TransactionTableViewCell.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 11/01/26.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func initialize(with transaction: Transaction) {
        titleLabel.text = transaction.note?.capitalized
        categoryLabel.text = transaction.category.capitalized
        amountLabel.text = "₹\(transaction.amount)"
    }
}
