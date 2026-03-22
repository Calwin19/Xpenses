//
//  PortfolioViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 26/01/26.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    @IBOutlet weak var assetsTableView: UITableView!
    @IBOutlet weak var netWorthLabel: UILabel!
    @IBOutlet weak var assetAllocationView: UIView!
    
    var assets = [Asset]()
    override func viewDidLoad() {
        super.viewDidLoad()
        assetsTableView.dataSource = self
        updateUI()
    }
    
    func updateUI() {
        APIService.shared.fetchAssets { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let assets):
                    self.assets = assets
                    self.calculateNetWorth()
                    self.assetsTableView.reloadData()
                case .failure:
                    print("Failed to fetch assets")
                }
            }
        }
    }
    
    func calculateNetWorth() {
        let total: Double = assets.reduce(0) { $0 + $1.latestValue}
        netWorthLabel.text = "₹\(formatWithCommas(total))"
    }
}

extension PortfolioViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetTableViewCell", for: indexPath) as! AssetTableViewCell
        cell.initialize(with: assets[indexPath.row])
        return cell
    }
}
