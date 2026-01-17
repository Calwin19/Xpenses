//
//  AddTransactionViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 10/01/26.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var dateSelected: Date = Date()
    var transaction: Transaction?
    private weak var acticeField: UIResponder?
    
    func initliseWithTransaction(_ transaction: Transaction) {
        self.transaction = transaction
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismiss()
        addDoneButtonToKeyboard()
        amountTextField.delegate = self
        categoryTextField.delegate = self
        noteTextField.delegate = self
        setupUI()
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
    
    func setupUI() {
        let Formatter = DateFormatter()
        Formatter.dateStyle = .medium
        if let transaction = transaction {
            amountTextField.text = "₹\(transaction.amount)"
            categoryTextField.text = transaction.category
            noteTextField.text = transaction.note
            dateButton.setTitle(Formatter.string(from: transaction.date), for: .normal)
            titleLabel.text = "Edit Expense"
            dateSelected = transaction.date
        } else {
            dateButton.setTitle(Formatter.string(from: dateSelected), for: .normal)
            titleLabel.text = "Add Expense"
        }
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        let bottomInset = keyboardFrame.height + 20
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addDoneButtonToKeyboard() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        toolbar.items = [flexSpace, doneButton]
        toolbar.tintColor = UIColor.systemGreen
        amountTextField.inputAccessoryView = toolbar
    }

    @objc func doneButtonTapped(){
        categoryTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dateButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.date = dateSelected
        alert.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
            datePicker.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -100)
        ])
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            self.dateSelected = datePicker.date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            self.dateButton.setTitle(formatter.string(from: self.dateSelected), for: .normal)
            DispatchQueue.main.async {
                self.noteTextField.becomeFirstResponder()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let transaction = transaction {
            let existingTransaction = Transaction(id: transaction.id, amount: Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0, categoty: categoryTextField.text ?? "", timestamp: dateSelected.timeIntervalSince1970, type: "Debit", note: noteTextField.text ?? "")
            APIService.shared.updateTransaction(existingTransaction) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let _):
                        NotificationCenter.default.post(name: .transactionsChanges, object: nil)
                    case .failure(let error):
                        print("Edit failed:", error)
                    }
                }
            }
        } else {
            let newTransaction = Transaction(amount: Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0, categoty: categoryTextField.text ?? "", timestamp: dateSelected.timeIntervalSince1970, type: "Debit", note: noteTextField.text ?? "")
            APIService.shared.addTransaction(newTransaction){
                NotificationCenter.default.post(name: .transactionsChanges, object: nil)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AddTransactionViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        acticeField = textField
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
        guard textField === amountTextField else {
            return true
        }
        if range.location == 0 { return false }
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField === amountTextField else { return }
        if textField.text == "₹" {
            textField.text = ""
        }
        acticeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === categoryTextField {
            view.endEditing(true)
            dateButtonTapped(dateButton)
        } else if textField === noteTextField {
            textField.resignFirstResponder()
        }
        return true
    }

}
