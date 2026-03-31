//
//  CalenderViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 24/03/26.
//

import UIKit
import FSCalendar

class CalenderViewController: UIViewController {
    
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var monthExpenseTitleLabel: UILabel!
    @IBOutlet weak var monthExpenseLabel: UILabel!
    
    var transactions = [Transaction]()
    var transactionSections = [TransactionSection]()
    private let spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.delegate = self
        calendarView.dataSource = self
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
        setupSpinner()
        getData()
        customiseCalendar()
        calendarView.placeholderType = .none
        calendarView.adjustsBoundingRectWhenChangingMonths = true
        transactionsTableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        self.edgesForExtendedLayout = [.all]
        self.extendedLayoutIncludesOpaqueBars = true
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
    
    func getData() {
        showSpinner()
        APIService.shared.fetchTransactions { result in
            DispatchQueue.main.async {
                self.hideSpinner()
                switch result {
                case .success(let data):
                    self.transactions = data.filter( {$0.type == "Debit" && ($0.borrower?.isEmpty ?? true)})
                    CategoryStore.shared.update(from: data)
                    self.calendarCurrentPageDidChange(self.calendarView)
                    self.calendarView.reloadData()
                case .failure(let error):
                    print("API Error:", error)
                    self.showError()
                }
            }
        }
    }
    
    func getDailyTotals() -> [Date: Double] {
        let grouped = Dictionary(grouping: transactions) {
            Calendar.current.startOfDay(for: $0.date)
        }
        var result: [Date: Double] = [:]
        for (date, txns) in grouped {
            let total = txns.reduce(0) { $0 + $1.amount }
            result[date] = total
        }
        return result
    }
    
    func customiseCalendar() {
        let primaryColor = UIColor(red: 34/255, green: 160/255, blue: 84/255, alpha: 1)
        calendarView.appearance.selectionColor = primaryColor
        calendarView.appearance.headerTitleColor = primaryColor
        calendarView.appearance.todayColor = .clear
        calendarView.appearance.weekdayTextColor = .white
        calendarView.appearance.titleDefaultColor = .white
        calendarView.appearance.titlePlaceholderColor = .gray
        calendarView.appearance.subtitleDefaultColor = .white
        calendarView.appearance.subtitlePlaceholderColor = .darkGray
    }
    
}

extension CalenderViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let totals = getDailyTotals()
        let day = Calendar.current.startOfDay(for: date)
        if let amount = totals[day], amount > 0 {
            return "₹\(Int(amount))"
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let filtered = transactions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        if filtered.isEmpty {
            self.transactionSections = []
        } else {
            let day = Calendar.current.startOfDay(for: date)
            self.transactionSections = [
                TransactionSection(date: day, transactions: filtered)
            ]
        }
        transactionsTableView.reloadData()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthExpenseTitleLabel.text = "Expenses for \(formatter.string(from: calendar.currentPage))".uppercased()
        let total = transactions.filter {
            Calendar.current.isDate($0.date, equalTo: calendar.currentPage, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
        monthExpenseLabel.text = "₹\(Int(total))"
    }
}

extension CalenderViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
}
