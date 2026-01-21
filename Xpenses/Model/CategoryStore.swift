//
//  CategoryStore.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 21/01/26.
//

import Foundation

final class CategoryStore {

    static let shared = CategoryStore()
    private init() {}

    private(set) var categories: [String] = []

    func update(from transactions: [Transaction]) {
        let unique = Set(
            transactions
                .compactMap { $0.category }
                .filter { !$0.isEmpty }
        )
        categories = Array(unique).sorted()
    }
}
