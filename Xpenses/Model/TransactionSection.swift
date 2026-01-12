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

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension JSONDecoder {
    static let isoDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
