//
//  AddAssetViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 26/01/26.
//

import UIKit

class AddAssetViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var institutionTextField: UITextField!
    
    var asset: Asset?

    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.delegate = self
        nameTextField.delegate = self
        typeTextField.delegate = self
        institutionTextField.delegate = self
        setupKeyboardDismisss()
        setUpUI()
    }
   
    func initialiseView(asset: Asset){
        self.asset = asset
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpUI(){
        if let asset {
            nameTextField.text = asset.name
            nameTextField.isUserInteractionEnabled = false
            typeTextField.text = asset.type
            typeTextField.isUserInteractionEnabled = false
            institutionTextField.text = asset.institution
            institutionTextField.isUserInteractionEnabled = false
            titleLabel.text = "Update Value"
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = keyboardFrame.height + 20
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    private func setupKeyboardDismisss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAssetButtonTapped(_ sender: UIButton) {
        if Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0 <= 0 {
            showToast(message: "Enter a valid amount")
            return
        }
        if var editedAsset = asset {
            editedAsset.latestValue = Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0
            APIService.shared.addAssetValue(newAsset: editedAsset){
                NotificationCenter.default.post(name: .assetsChanged, object: nil)
            }
        } else {
            let newAsset = Asset(name: nameTextField.text ?? "", type: typeTextField.text ?? "", institution: institutionTextField.text ?? "", latestValue: Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0)
            APIService.shared.addNewAsset(newAsset: newAsset) {
                APIService.shared.addAssetValue(newAsset: newAsset){
                    NotificationCenter.default.post(name: .assetsChanged, object: nil)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AddAssetViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let rect = textField.convert(textField.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
        guard textField === amountTextField else { return }
        if textField.text?.isEmpty == true {
            textField.text = "₹"
        }
        DispatchQueue.main.async {
            let position = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === amountTextField {
            if range.location == 0 { return false }
            return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField === amountTextField else { return }
        if textField.text == "₹" {
            textField.text = ""
        }
    }
    
}
