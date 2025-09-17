//
//  SettingsViewController.swift
//  regex
//
//  Created by Augustin on 16.09.25.
//
import UIKit
import Security

class SettingsViewController: UIViewController {

    let oldPasswordField = UITextField()
    let newPasswordField = UITextField()
    let confirmPasswordField = UITextField()
    let saveButton = UIButton(type: .system)
    let removeButton = UIButton(type: .system)
    var hasExistingPassword = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        // Check if a password already exists
       if KeychainHelper.standard.readPassword(service: "RegexBlocker", account: "appLock") != nil {
           hasExistingPassword = true
       }
        
        setupUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.oldPasswordField.endEditing(true)
        self.newPasswordField.endEditing(true)
        self.confirmPasswordField.endEditing(true)
    }

    func setupUI() {
        oldPasswordField.translatesAutoresizingMaskIntoConstraints = false
        oldPasswordField.placeholder = "Current password"
        oldPasswordField.isSecureTextEntry = true
        oldPasswordField.borderStyle = .roundedRect
        // Gray out + disable if no existing password
        if !hasExistingPassword {
            oldPasswordField.isEnabled = false
            oldPasswordField.backgroundColor = UIColor.systemGray5
            oldPasswordField.text = ""
        }
        view.addSubview(oldPasswordField)

        newPasswordField.translatesAutoresizingMaskIntoConstraints = false
        newPasswordField.placeholder = "New password"
        newPasswordField.isSecureTextEntry = true
        newPasswordField.borderStyle = .roundedRect
        view.addSubview(newPasswordField)

        confirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordField.placeholder = "Confirm new password"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.borderStyle = .roundedRect
        view.addSubview(confirmPasswordField)

        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save Password", for: .normal)
        saveButton.addTarget(self, action: #selector(savePassword), for: .touchUpInside)
        view.addSubview(saveButton)

        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.setTitle("Remove Password", for: .normal)
        removeButton.setTitleColor(.systemRed, for: .normal)
        removeButton.addTarget(self, action: #selector(removePassword), for: .touchUpInside)
        removeButton.isEnabled = true
        // Gray out + disable if no existing password
        if !hasExistingPassword {
            removeButton.isEnabled = false
            removeButton.setTitleColor(.systemGray3, for: .normal)
        }
        view.addSubview(removeButton)

        NSLayoutConstraint.activate([
            oldPasswordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            oldPasswordField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            oldPasswordField.widthAnchor.constraint(equalToConstant: 250),

            newPasswordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newPasswordField.topAnchor.constraint(equalTo: oldPasswordField.bottomAnchor, constant: 20),
            newPasswordField.widthAnchor.constraint(equalToConstant: 250),

            confirmPasswordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordField.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 20),
            confirmPasswordField.widthAnchor.constraint(equalToConstant: 250),

            saveButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            removeButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            removeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func savePassword() {
        let oldInput = oldPasswordField.text ?? ""
        let newPass = newPasswordField.text ?? ""
        let confirmPass = confirmPasswordField.text ?? ""

        // Validate old password if one exists
        if let stored = KeychainHelper.standard.readPassword(service: "RegexBlocker", account: "appLock") {
            guard stored == oldInput else {
                showAlert("Error", "Current password is incorrect.")
                return
            }
        }

        // Validate new password match
        guard !newPass.isEmpty else {
            showAlert("Error", "New password cannot be empty.")
            return
        }

        guard newPass == confirmPass else {
            showAlert("Error", "New passwords do not match.")
            return
        }

        // Save new password
        KeychainHelper.standard.save(password: newPass, service: "RegexBlocker", account: "appLock")
        showAlert("Success", "Password updated successfully.")
        clearFields()
        if let defaults = UserDefaults(suiteName: "group.com.augustin.blocker") {
            defaults.set(true, forKey: "hasPassword")
            defaults.synchronize()
        }
    }

    @objc func removePassword() {
        let oldInput = oldPasswordField.text ?? ""

        if let stored = KeychainHelper.standard.readPassword(service: "RegexBlocker", account: "appLock") {
            guard stored == oldInput else {
                showAlert("Error", "Current password is incorrect.")
                return
            }
            KeychainHelper.standard.deletePassword(service: "RegexBlocker", account: "appLock")
            showAlert("Success", "Password removed.")
            clearFields()
            if let defaults = UserDefaults(suiteName: "group.com.augustin.blocker") {
                defaults.set(false, forKey: "hasPassword")
                defaults.synchronize()
            }
        } else {
            showAlert("Info", "No password is set.")
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func clearFields() {
        oldPasswordField.text = ""
        newPasswordField.text = ""
        confirmPasswordField.text = ""
    }
}
