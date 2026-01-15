//
//  TransactionDateTableViewCell.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 11/01/26.
//

import UIKit

class TransactionDateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    func initliseTransactionDateTableViewCell(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        dateLabel.text = formatter.string(from: date)
    }
}
