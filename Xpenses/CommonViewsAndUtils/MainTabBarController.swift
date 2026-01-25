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
        disableMiddleTab()
        setupAddButton()
        configureTabBarAppearance()
    }
    
    private func attachNavDelegates() {
        viewControllers?.forEach { vc in
            if let nav = vc as? UINavigationController {
                nav.delegate = self
            }
        }
    }

    private func disableMiddleTab() {
        guard let items = tabBar.items, items.count == 5 else { return }

        let middleItem = items[2]
        middleItem.isEnabled = false
        middleItem.title = ""
        middleItem.image = nil
    }

    private func setupAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = UIColor(
            red: 34/255,
            green: 160/255,
            blue: 84/255,
            alpha: 1
        )
        addButton.layer.cornerRadius = 32
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white

        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.4
        addButton.layer.shadowRadius = 10
        addButton.layer.shadowOffset = CGSize(width: 0, height: 6)

        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),
            addButton.widthAnchor.constraint(equalToConstant: 64),
            addButton.heightAnchor.constraint(equalToConstant: 64)
        ])
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemGreen
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen
        ]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    @objc private func addTapped() {
        guard let nav = selectedViewController as? UINavigationController else { return }
        let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTransactionViewController") as! AddTransactionViewController
        nav.pushViewController(addVC, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(addButton)
        tabBar.items?.forEach {
            $0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {}

extension MainTabBarController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        addButton.isHidden = viewController.hidesBottomBarWhenPushed
    }
}
