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
    @IBOutlet weak var transactionTypeView: UIView!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    
    func initialize(with transaction: Transaction) {
        titleLabel.text = transaction.note?.capitalized
        categoryLabel.text = transaction.category?.capitalized
        if let borrower = transaction.borrower, !borrower.isEmpty {
            amountLabel.text = "-₹\(formatWithCommas(transaction.amount))"
            amountLabel.textColor = UIColor(hex: "FF3445")
            if transaction.didPay {
                transactionTypeView.isHidden = false
                transactionTypeView.backgroundColor = UIColor(hex: "E9A23B")
                transactionTypeLabel.textColor = UIColor(hex: "1C1C1E")
                transactionTypeView.layer.borderWidth = 0
                transactionTypeLabel.text = "Recovered"
            } else {
                transactionTypeView.isHidden = false
                transactionTypeView.backgroundColor = .clear
                transactionTypeLabel.textColor = UIColor(hex: "E9A23B")
                transactionTypeView.layer.borderWidth = 1
                transactionTypeLabel.text = "Recoverable"
                transactionTypeView.layer.borderColor = UIColor(hex: "E9A23B").cgColor
            }
        } else if transaction.type == "Debit" {
            amountLabel.text = "-₹\(formatWithCommas(transaction.amount))"
            amountLabel.textColor = UIColor(hex: "FF3445")
            transactionTypeView.isHidden = true
        } else {
            amountLabel.text = "₹\(formatWithCommas(transaction.amount))"
            amountLabel.textColor = UIColor(hex: "3CE36A")
            transactionTypeView.isHidden = true
        }
    }
}
