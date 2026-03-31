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
        let calender = Calendar.self
        if calender.current.isDateInToday(date) {
            dateLabel.text = "TODAY"
        } else if calender.current.isDate(date, inSameDayAs: Date.now.startOfDay()-1) {
            dateLabel.text = "YESTERDAY"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            dateLabel.text = formatter.string(from: date)
        }
    }
}
