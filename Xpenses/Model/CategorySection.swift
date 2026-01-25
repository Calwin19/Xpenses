//
//  CategorySection.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 21/01/26.
//

import Foundation

struct CategorySection {
    let category: String
    let transactions: [Transaction]
    var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
}
