//
//  TransactionDTO.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 12/01/26.
//

import Foundation

struct TransactionDTO: Codable {
    let id: UUID
    let amount: Double
    let category: String?
    let date: TimeInterval
    let type: String
    let note: String?
}
