//
//  APIService.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 12/01/26.
//

import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    private let baseURL = "http://140.245.198.94"
    func fetchTransactions(completion: @escaping (Result<[Transaction], Error>) -> Void) {
        let url = URL(string: "\(baseURL)/transactions")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError()))
                return
            }
            do {
                let transactions = try JSONDecoder.isoDecoder
                    .decode([Transaction].self, from: data)
                completion(.success(transactions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func addTransaction(_ transaction: Transaction, completion: (() -> Void)? = nil) {
        let url = URL(string: "\(baseURL)/transactions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dto = TransactionDTO(
            id: transaction.id,
            amount: transaction.amount,
            category: transaction.category,
            date: transaction.timestamp,
            type: transaction.type,
            note: transaction.note,
            borrower: transaction.borrower,
            didPay: transaction.didPay
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(dto)
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion?()
            }
        }.resume()
    }

    func deleteTransaction(id: UUID, completion: (() -> Void)? = nil) {
        let url = URL(string: "\(baseURL)/transactions/\(id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                completion?()
            }
        }.resume()
    }

    func updateTransaction(_ transaction: Transaction, completion: ((Result<Transaction, Error>) -> Void)? = nil) {
        let url = URL(string: "\(baseURL)/transactions/\(transaction.id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dto = TransactionDTO(
            id: transaction.id,
            amount: transaction.amount,
            category: transaction.category,
            date: transaction.timestamp,
            type: transaction.type,
            note: transaction.note,
            borrower: transaction.borrower,
            didPay: transaction.didPay
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try? encoder.encode(dto)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }
            guard let data = data else {
                completion?(.failure(NSError()))
                return
            }
            do {
                let updated = try JSONDecoder.isoDecoder.decode(Transaction.self, from: data)
                DispatchQueue.main.async {
                    completion?(.success(updated))
                }
            } catch {
                completion?(.failure(error))
            }
        }.resume()
    }
}
