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
    
    private let spinner = UIActivityIndicatorView(style: .large)
    var transactionSections = [TransactionSection]()
    var transactions = [Transaction]()
    var monthFilterView: MonthFilterView!
    var selectedMonth = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
        setupMonthFilterView()
        setupSpinner()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getData() {
        showSpinner()
        APIService.shared.fetchTransactions { result in
            DispatchQueue.main.async {
                self.hideSpinner()
                switch result {
                case .success(let data):
                    self.transactions = data
                    self.reloadTableView()

                case .failure(let error):
                    print("API Error:", error)
                    self.showError()
                }
            }
        }
    }
    
    func makeSections(from transactions: [Transaction]) -> [TransactionSection] {
        let grouped = Dictionary(grouping: transactions) {
            $0.date.startOfDay()
        }
        let sections = grouped.map {
            TransactionSection(date: $0.key, transactions: $0.value.sorted { $0.date > $1.date })
        }.sorted { $0.date > $1.date }
        return sections
    }
    
    func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func showSpinner() {
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func hideSpinner() {
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    func showError() {
        let alert = UIAlertController(title: "Please wait", message: "Waking up server, this may take a few seconds.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        transactionSections = makeSections(from: transactions).filter { Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)}.sorted { $0.date > $1.date }
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
            let transaction = self.transactionSections[indexPath.section].transactions[indexPath.row - 1]
            APIService.shared.deleteTransaction(id: transaction.id) {
                if let index = self.transactions.firstIndex(where: { $0.id == transaction.id }) {
                    self.transactions.remove(at: index)
                }
                self.reloadTableView()
                completion(true)
            }
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
