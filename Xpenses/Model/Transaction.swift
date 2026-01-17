//
//  Transaction.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 10/01/26.
//

import Foundation

struct Transaction: Codable, Identifiable, Sendable {
    
    var id: UUID
    var amount: Double
    var category: String?
    var timestamp: TimeInterval
    var type: String
    var note: String?
    var source: String?
    var destination: String?

    init(id: UUID = UUID(), amount: Double, categoty: String, timestamp: TimeInterval, type: String, note: String){
        self.id = id
        self.amount = amount
        self.category = categoty
        self.timestamp = timestamp
        self.type = type
        self.note = note
    }
}

extension Transaction {
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}
