//
//  Extenstions.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 19/01/26.
//

import UIKit

extension Date {
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}

extension JSONDecoder {
    static let isoDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

func formatWithCommas(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2

    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

extension UIViewController {
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true

        let padding: CGFloat = 16
        let maxWidth = self.view.frame.width - 40
        let size = toastLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        toastLabel.frame = CGRect(x: 20, y: self.view.frame.height - size.height - 120, width: maxWidth, height: size.height + padding)
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.25) { toastLabel.alpha = 1 } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: duration,options: .curveEaseOut) {
                toastLabel.alpha = 0
            } completion: { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }

}
