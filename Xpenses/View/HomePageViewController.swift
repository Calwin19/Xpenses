//
//  HomePageViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 11/01/26.
//

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var totalSpendingLabel: UILabel!
    
    var transactions = [Transaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactions = Storage.load()
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
    }
}

extension HomePageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transactionCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        transactionCell.initialize(with: transactions[indexPath.row])
        return transactionCell
    }
    
}

enum TransactionListType {
    case transaction: Transaction
    case date: Date
}
