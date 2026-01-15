//
//  CustomTabBar.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 10/01/26.
//

import UIKit

class CustomTabBar: UITabBar {

    private var shapeLayer: CAShapeLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        addShape()
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.fillColor = UIColor(
            red: 14/255,
            green: 24/255,
            blue: 18/255,
            alpha: 1
        ).cgColor
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: -4)
        shapeLayer.shadowOpacity = 0.35
        shapeLayer.shadowRadius = 10
        if let oldLayer = self.shapeLayer {
            layer.replaceSublayer(oldLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {
        let height: CGFloat = 80
        let centerX = bounds.width / 2
        let notchRadius: CGFloat = 34
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: centerX - notchRadius - 12, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: centerX, y: -notchRadius),
            controlPoint: CGPoint(x: centerX - notchRadius, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: centerX + notchRadius + 12, y: 0),
            controlPoint: CGPoint(x: centerX + notchRadius, y: 0)
        )
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        return path.cgPath
    }
}

