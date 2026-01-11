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
    
    var transactionSections = [TransactionSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionSections = Storage.load()
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transactionSections = Storage.load()
        transactionsTableView.reloadData()
    }
    
    func sumOfTransactions() {
        totalSpendingLabel.text = "₹\(transactionSections.flatMap{ $0.transactions }.reduce(0) {$0 + $1.amount})"
    }
    
    func reloadTableView() {
        transactionSections = Storage.load()
        transactionsTableView.reloadData()
    }
}

extension HomePageViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        transactionSections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactionSections[section].transactions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let transactionDateCell = tableView.dequeueReusableCell(withIdentifier: "TransactionDateTableViewCell") as! TransactionDateTableViewCell
            transactionDateCell.initliseTransactionDateTableViewCell(date: transactionSections[indexPath.section].date)
            return transactionDateCell
        } else {
            let transactionCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
            transactionCell.initialize(with: transactionSections[indexPath.section].transactions[indexPath.row - 1])
            return transactionCell
        }
    }
    
    private func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            Storage.delete(indexPath: indexPath)
            self.reloadTableView()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
}
