//
//  Storage.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 10/01/26.
//

import Foundation

struct Storage {
    
    static let keyTransactions = "Transactions"
    
    static func save(_ transation: Transaction){
        var trasactions = load()
        trasactions.append(transation)
        let data = try? JSONEncoder().encode(trasactions)
        UserDefaults.standard.set(data, forKey: keyTransactions)
    }
    
    static func load() -> [Transaction]{
        guard let data = UserDefaults.standard.data(forKey: keyTransactions) else { return []}
        return (try? JSONDecoder().decode([Transaction].self, from: data)) ?? []
    }
}
