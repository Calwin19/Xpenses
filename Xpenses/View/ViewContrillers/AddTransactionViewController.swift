//
//  AddTransactionViewController.swift
//  Xpenses
//
//  Created by Calwin QuickRide on 10/01/26.
//

import UIKit

class AddTransactionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var expenseButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var selectionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var borrowerView: UIView!
    @IBOutlet weak var borrowerNameTextField: UITextField!
    @IBOutlet weak var didPaySwitch: UISwitch!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    
    var dateSelected: Date = Calendar.current.startOfDay(for: Date())
    var transaction: Transaction?
    private weak var acticeField: UIResponder?
    var selectedTab: TransactionTab = .expense
    var filteredCategories: [String] = []
    var savedCategories: [String] = []
    
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
        savedCategories = CategoryStore.shared.categories
        filterCategories(with: "")
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.isHidden = true
        categoryTableView.backgroundColor = UIColor(hex: "1C1C1E")
        categoryTableView.layer.cornerRadius = 8
        categoryTableView.layer.borderWidth = 1
        categoryTableView.layer.borderColor = UIColor.systemGray4.cgColor
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
            selectedTab = transaction.type == "Debit" ? .expense : .income
            switchTab(to: selectedTab)
            amountTextField.text = "₹\(transaction.amount)"
            categoryTextField.text = transaction.category
            dateButton.setTitle(Formatter.string(from: transaction.date), for: .normal)
            dateSelected = transaction.date
            borrowerNameTextField.text = transaction.borrower
            didPaySwitch.isOn = transaction.didPay
            noteTextField.text = transaction.note
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
    
    func switchTab(to tab: TransactionTab) {
        selectedTab = tab
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut]) {
            if tab == .expense {
                self.titleLabel.text = self.transaction == nil ? "Add Expense" : "Edit Expense"
                self.saveButton.setTitle("Save Expense", for: .normal)
                self.selectionLeadingConstraint.constant = 105
                self.incomeButton.tintColor = UIColor(hex: "00752D")
                self.expenseButton.tintColor = .white
                self.borrowerView.isHidden = false
            } else {
                self.titleLabel.text = self.transaction == nil ? "Add Income" : "Edit Income"
                self.saveButton.setTitle("Save Income", for: .normal)
                self.selectionLeadingConstraint.constant = 5
                self.incomeButton.tintColor = .white
                self.expenseButton.tintColor = UIColor(hex: "00752D")
                self.borrowerView.isHidden = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func filterCategories(with text: String) {
        if text.isEmpty {
            filteredCategories = savedCategories
            categoryTableView.reloadData()
            return
        }

        filteredCategories = savedCategories.filter {
            $0.lowercased().contains(text.lowercased())
        }

        categoryTableView.isHidden = filteredCategories.isEmpty
        categoryTableView.reloadData()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
        
    @IBAction func expenseTapped(_ sender: UIButton) {
        switchTab(to: .expense)
    }
    
    @IBAction func incomeTapped(_ sender: UIButton) {
        switchTab(to: .income)
    }
    
    @IBAction func categoryDropDownTapped(_ sender: UIButton) {
        categoryTableView.isHidden.toggle()
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
    
    @IBAction func didPayButtonTapped(_ sender: UISwitch) {
        if borrowerNameTextField.text?.isEmpty == true {
            sender.isOn = false
            showToast(message: "Enter a name")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0 <= 0 {
            showToast(message: "Enter a valid amount")
            return
        }
        if let transaction = transaction {
            let existingTransaction = Transaction(id: transaction.id, amount: Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0, categoty: categoryTextField.text ?? "", timestamp: dateSelected.timeIntervalSince1970, type: selectedTab == .expense ? "Debit" : "Credit", note: noteTextField.text ?? "", borrower: borrowerNameTextField.text ?? "", didPay: didPaySwitch.isOn)
            APIService.shared.updateTransaction(existingTransaction) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success( _):
                        NotificationCenter.default.post(name: .transactionsChanges, object: nil)
                    case .failure(let error):
                        print("Edit failed:", error)
                    }
                }
            }
        } else {
            let newTransaction = Transaction(amount: Double(amountTextField.text?.replacingOccurrences(of: "₹", with: "") ?? "") ?? 0, categoty: categoryTextField.text ?? "", timestamp: dateSelected.timeIntervalSince1970, type: selectedTab == .expense ? "Debit" : "Credit", note: noteTextField.text ?? "", borrower: borrowerNameTextField.text ?? "", didPay: didPaySwitch.isOn)
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
        if textField === amountTextField {
            if range.location == 0 { return false }
            return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
        }
        if textField === categoryTextField {
            let currentText = textField.text ?? ""
            let updatedText = (currentText as NSString)
                .replacingCharacters(in: range, with: string)
            
            filterCategories(with: updatedText)
            return true
        }
        return true
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

extension AddTransactionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCategories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = filteredCategories[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selected = filteredCategories[indexPath.row]
        categoryTextField.text = selected
        categoryTableView.isHidden = true
        noteTextField.becomeFirstResponder()
    }
}


enum TransactionTab {
    case expense
    case income
}
