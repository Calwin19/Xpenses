//
//  AnalysisViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 22/01/26.
//

import UIKit
import DGCharts

class AnalysisViewController: UIViewController {
    

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var monthFilterContainer: UIView!
    
    var allTransactions: [Transaction] = []
    var selectedMonthransactions: [Transaction] = []
    var categorySections: [CategorySection] = []
    var monthFilterView: MonthFilterView!
    var selectedMonth = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        transactionsTableView.dataSource = self
        pieChartView.delegate = self
        transactionsTableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
        setupMonthFilterView()
        self.edgesForExtendedLayout = [.all]
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    func getData() {
        APIService.shared.fetchTransactions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.allTransactions = data.filter( {$0.type == "Debit" && ($0.borrower?.isEmpty ?? true)})
                    self.selectedMonthransactions = self.allTransactions.filter { Calendar.current.isDate($0.date, equalTo: self.selectedMonth, toGranularity: .month)}.sorted { $0.date > $1.date }
                    self.categorySections = self.makeCategorySections(from: self.selectedMonthransactions)
                    self.updatePieChart(with: self.categorySections)
                    self.transactionsTableView.reloadData()
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }

    func makeCategorySections(from transactions: [Transaction]) -> [CategorySection] {
        let grouped = Dictionary(grouping: transactions.filter({ $0.type == "Debit" })) {
            $0.category ?? "Uncategorized"
        }

        return grouped.map { CategorySection(category: $0.key, transactions: $0.value) }.sorted { $0.totalAmount > $1.totalAmount }
    }

    func updatePieChart(with sections: [CategorySection]) {
        let entries = sections.map { PieChartDataEntry(value: $0.totalAmount, label: $0.category) }
        let dataSet = PieChartDataSet(entries: entries)
        let data = PieChartData(dataSet: dataSet)
        let formatter = NumberFormatter()
        dataSet.colors = ChartColorTemplates.material()
        dataSet.sliceSpace = 2
        dataSet.valueTextColor = .clear
        dataSet.sliceSpace = 2
        dataSet.selectionShift = 8
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.valueLineColor = .label
        pieChartView.drawHoleEnabled = false
        pieChartView.usePercentValuesEnabled = true
        pieChartView.legend.enabled = false
        pieChartView.setExtraOffsets(left: 50, top: 10, right: 50, bottom: 10)
        pieChartView.data = data
        pieChartView.animate(xAxisDuration: 0.8, yAxisDuration: 0.8, easingOption: .easeOutBack)
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 12, weight: .semibold))
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.percentSymbol = " %"
    }

    func setupMonthFilterView() {
        monthFilterView = Bundle.main.loadNibNamed("MonthFilterView", owner: self)?.first as? MonthFilterView
        monthFilterView.frame = monthFilterContainer.bounds
        monthFilterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        monthFilterView.delegate = self
        monthFilterView.update(month: selectedMonth)
        monthFilterContainer.addSubview(monthFilterView)
    }

    func reloadTableView() {
        self.selectedMonthransactions = self.allTransactions.filter { Calendar.current.isDate($0.date, equalTo: self.selectedMonth, toGranularity: .month)}.sorted { $0.date > $1.date }
        self.categorySections = self.makeCategorySections(from: self.selectedMonthransactions)
        self.updatePieChart(with: self.categorySections)
        self.transactionsTableView.reloadData()
    }

}

extension AnalysisViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        categorySections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categorySections[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = categorySections[section]
        return "\(section.category)  •  ₹\(section.totalAmount)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        cell.initialize(with: categorySections[indexPath.section].transactions[indexPath.row])
        return cell
    }

}

extension AnalysisViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Selected:", entry.y)
    }
}

extension AnalysisViewController: MonthFilterViewDelegate {
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

