//
//  TransactionSection.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 11/01/26.
//

import Foundation

struct TransactionSection: Codable {
    let date: Date
    var transactions: [Transaction]
}
