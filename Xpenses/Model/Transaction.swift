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
    var date: Date
    var type: String
    var note: String?
    
    init(id: UUID = UUID(), amount: Double, categoty: String, date: Date, type: String, note: String){
        self.id = id
        self.amount = amount
        self.category = categoty
        self.date = date
        self.type = type
        self.note = note
    }
}
