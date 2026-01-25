//
//  MonthFilterView.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 12/01/26.
//

import UIKit

class MonthFilterView: UIView {

    @IBOutlet weak var monthButton: UIButton!
    
    weak var delegate: MonthFilterViewDelegate?

    @IBAction func dropDownButtonTapped(_ sender: UIButton) {
        delegate?.didTapMonth()
    }
    
    func update(month: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthButton.setTitle(formatter.string(from: month), for: .normal) 
    }
}
