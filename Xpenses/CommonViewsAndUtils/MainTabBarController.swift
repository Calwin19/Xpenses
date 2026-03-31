//
//  ViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 09/01/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let addButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        attachNavDelegates()
        configureTabBarAppearance()
        setupAddButton()
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    private func attachNavDelegates() {
        viewControllers?.forEach { vc in
            if let nav = vc as? UINavigationController {
                nav.delegate = self
            }
        }
    }

    private func setupAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = UIColor(hex: "3CE36A")
        addButton.layer.cornerRadius = 24
        addButton.setImage(UIImage(named: "PLUS"), for: .normal)
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -4
            ),
            addButton.widthAnchor.constraint(equalToConstant: 48),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        addButton.layer.masksToBounds = false
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(hex: "1C211E").withAlphaComponent(0.9)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func addTapped() {
        guard let nav = selectedViewController as? UINavigationController else { return }
        if selectedIndex == 4 {
            let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddAssetViewController") as! AddAssetViewController
            nav.pushViewController(addVC, animated: true)
        } else {
            let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTransactionViewController") as! AddTransactionViewController
            nav.pushViewController(addVC, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(addButton)
        let height: CGFloat = 64
        let margin: CGFloat = 16
        tabBar.frame = CGRect( x: margin, y: view.frame.height - height - 20, width: view.frame.width - (margin * 2), height: height )
        tabBar.layer.cornerRadius = height / 2
        tabBar.layer.masksToBounds = true
        let offset = (tabBar.frame.height - 42) / 2
        tabBar.items?.forEach { $0.title = nil
            $0.imageInsets = UIEdgeInsets(top: offset, left: 0, bottom: -offset, right: 0)
            $0.image = $0.image?.withRenderingMode(.alwaysOriginal)
            $0.selectedImage = $0.selectedImage?.withRenderingMode(.alwaysOriginal)
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return true }
        if index == 2 {
            addTapped()
            return false
        }
        return true
    }
}

extension MainTabBarController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        addButton.isHidden = viewController.hidesBottomBarWhenPushed
    }
}
