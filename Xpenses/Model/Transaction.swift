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
    var borrower: String?
    var didPay: Bool = false

    init(id: UUID = UUID(), amount: Double, categoty: String, timestamp: TimeInterval, type: String, note: String, borrower: String, didPay: Bool){
        self.id = id
        self.amount = amount
        self.category = categoty
        self.timestamp = timestamp
        self.type = type
        self.note = note
        self.borrower = borrower
        self.didPay = didPay
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case category
        case timestamp
        case type
        case note
        case source
        case destination
        case borrower
        case didPay = "did_pay"
    }
}

extension Transaction {
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
}
