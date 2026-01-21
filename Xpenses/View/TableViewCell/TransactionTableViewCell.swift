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
            if transaction.didPay {
                transactionTypeView.backgroundColor = UIColor(hex: "E9A23B")
                transactionTypeLabel.textColor = UIColor(hex: "1C1C1E")
                transactionTypeView.layer.borderWidth = 0
                transactionTypeLabel.text = "BORROWED (PAID)"
            } else {
                transactionTypeView.backgroundColor = .clear
                transactionTypeLabel.textColor = UIColor(hex: "E9A23B")
                transactionTypeView.layer.borderWidth = 1
                transactionTypeLabel.text = "BORROWED"
                transactionTypeView.layer.borderColor = UIColor(hex: "E9A23B").cgColor
            }
        } else if transaction.type == "Debit" {
            amountLabel.text = "-₹\(formatWithCommas(transaction.amount))"
            transactionTypeView.backgroundColor = UIColor(hex: "333334")
            transactionTypeLabel.textColor = UIColor(hex: "8D98A9")
            transactionTypeView.layer.borderWidth = 0
            transactionTypeLabel.text = "DEBIT"
        } else {
            amountLabel.text = "₹\(formatWithCommas(transaction.amount))"
            transactionTypeView.backgroundColor = UIColor(hex: "1A2B26")
            transactionTypeLabel.textColor = UIColor(hex: "68CC9A")
            transactionTypeView.layer.borderWidth = 0
            transactionTypeLabel.text = "CREDIT"
        }
    }
}
