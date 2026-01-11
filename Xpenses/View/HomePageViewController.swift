//
//  HomePageViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 11/01/26.
//

import UIKit

protocol MonthFilterViewDelegate: AnyObject {
    func didTapMonth()
}

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var totalSpendingLabel: UILabel!
    @IBOutlet weak var monthFilterContainer: UIView!
    
    var transactionSections = [TransactionSection]()
    var monthFilterView: MonthFilterView!
    var selectedMonth = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
        setupMonthFilterView()
        reloadTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
    }
    
    func setupMonthFilterView() {
        monthFilterView = Bundle.main.loadNibNamed("MonthFilterView", owner: self)?.first as? MonthFilterView
        monthFilterView.frame = monthFilterContainer.bounds
        monthFilterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        monthFilterView.delegate = self
        monthFilterView.update(month: selectedMonth)
        monthFilterContainer.addSubview(monthFilterView)
    }

    func sumOfTransactions() {
        totalSpendingLabel.text = "₹\(transactionSections.flatMap{ $0.transactions }.reduce(0) {$0 + $1.amount})"
    }
    
    func reloadTableView() {
        let allSections = Storage.load()
        transactionSections = allSections.filter { Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)}.sorted { $0.date > $1.date }
        sumOfTransactions()
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == 0 { return nil }
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            Storage.delete(indexPath: indexPath)
            self.reloadTableView()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
}

extension HomePageViewController: MonthFilterViewDelegate {
    func didTapMonth() {
        showMonthPicker()
    }
    
    func showMonthPicker() {
        let alert = UIAlertController(title: "Select Month", message: nil, preferredStyle: .actionSheet)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        for offset in 0..<12 {
            if let date = Calendar.current.date(byAdding: .month, value: -offset, to: Date()) {
                alert.addAction(UIAlertAction(title: formatter.string(from: date), style: .default) { _ in
                    self.selectedMonth = date
                    self.monthFilterView.update(month: date)
                    self.reloadTableView()
                })
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

}
