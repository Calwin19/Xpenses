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
    @IBOutlet weak var assetAllocationView: UIStackView!
    
    var assets = [Asset]()
    override func viewDidLoad() {
        super.viewDidLoad()
        assetsTableView.dataSource = self
        assetsTableView.delegate = self
        updateUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .assetsChanged, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func updateUI() {
        APIService.shared.fetchAssets { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let assets):
                    self.assets = assets
                    self.calculateNetWorth()
                    self.setupAssetBar()
                    self.assetsTableView.reloadData()
                case .failure:
                    print("Failed to fetch assets")
                }
            }
        }
    }
    
    func colorForAsset(_ name: String) -> UIColor {
        let baseColors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .systemPink, .systemTeal,
            .systemIndigo, .systemYellow
        ]
        let stableHash = name.unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1.value)
        }
        return baseColors[stableHash % baseColors.count]
    }
    
    func setupAssetBar() {
        assetAllocationView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        let total = assets.reduce(0) { $0 + $1.latestValue }
        guard total > 0 else { return }
        for asset in assets {
            let percentage = asset.latestValue / total
            let segment = UIView()
            segment.backgroundColor = colorForAsset(asset.name)
            segment.layer.cornerRadius = 4
            segment.clipsToBounds = true
            assetAllocationView.addArrangedSubview(segment)
            segment.translatesAutoresizingMaskIntoConstraints = false
            segment.widthAnchor.constraint(equalTo: assetAllocationView.widthAnchor, multiplier: percentage).isActive = true
        }
    }
    
    func calculateNetWorth() {
        let total: Double = assets.reduce(0) { $0 + $1.latestValue}
        netWorthLabel.text = "₹\(formatWithCommas(total))"
    }
}

extension PortfolioViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssetTableViewCell", for: indexPath) as! AssetTableViewCell
        cell.initialize(with: assets[indexPath.row])
        cell.nameLabel.textColor = colorForAsset(assets[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let updateAssetViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAssetViewController") as! AddAssetViewController
        updateAssetViewController.initialiseView(asset: assets[indexPath.row])
        navigationController?.pushViewController(updateAssetViewController, animated: true)
    }
}
