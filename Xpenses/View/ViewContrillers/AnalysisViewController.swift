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
    
    var transactions: [Transaction] = []
    var categorySections: [CategorySection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        transactionsTableView.dataSource = self
        pieChartView.delegate = self
        transactionsTableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
    }
    
    func getData() {
        APIService.shared.fetchTransactions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.transactions = data
                    self.categorySections = self.makeCategorySections(from: self.transactions)
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
