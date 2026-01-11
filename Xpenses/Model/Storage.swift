//
//  Storage.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 10/01/26.
//

import UIKit

struct Storage {
    
    static let keyTransactionSections = "transactionSections"
    
    static func save(_ transation: Transaction){
        var transactionSections = load()
        let day = Calendar.current.startOfDay(for: transation.date)
        if let index = transactionSections.firstIndex(where: {Calendar.current.isDate($0.date, inSameDayAs: day)}) {
            transactionSections[index].transactions.insert(transation, at: 0)
        } else {
            transactionSections.insert(TransactionSection(date: day, transactions: [transation]), at: 0)
        }
        let data = try? JSONEncoder().encode(transactionSections)
        UserDefaults.standard.set(data, forKey: keyTransactionSections)
    }
    
    static func load() -> [TransactionSection]{
        guard let data = UserDefaults.standard.data(forKey: keyTransactionSections) else { return []}
        return (try? JSONDecoder().decode([TransactionSection].self, from: data)) ?? []
    }
    
    static func delete(indexPath: IndexPath) {
        var transactionSections = load()
        transactionSections[indexPath.section].transactions.remove(at: indexPath.row - 1)
        if transactionSections[indexPath.section].transactions.isEmpty {
            transactionSections.remove(at: indexPath.section)
        }
        let data = try? JSONEncoder().encode(transactionSections)
        UserDefaults.standard.set(data, forKey: keyTransactionSections)
    }
}
