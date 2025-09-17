import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController {

    // MARK: - UI Elements
    let textView = UITextView()
    let saveButton = UIButton(type: .system)
    let clearButton = UIButton(type: .system)
    let statusLabel = UILabel()
    var blurView: UIVisualEffectView?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "RegexBlocker Settings"

        setupTextView()
        setupButtons()
        setupStatusLabel()
        loadPatterns()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "questionmark.circle.dashed"),
            style: .plain,
            target: self,
            action: #selector(openHelp)
        )
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self,
                                                  selector: #selector(handleAppDidBecomeActive(notification:)),
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    @objc func openSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc func openHelp() {
        let helpVC = HelpViewController()
        navigationController?.pushViewController(helpVC, animated: true)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.textView.endEditing(true)
    }
    
    func promptForPassword(correctPassword: String) {
        // If blur is not already added, add it
        if blurView == nil {
            let blurEffect = UIBlurEffect(style: .systemChromeMaterial) // nice frosted look
            let bv = UIVisualEffectView(effect: blurEffect)
            bv.frame = view.bounds
            bv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(bv)
            blurView = bv
        }

        let alert = UIAlertController(title: "Enter Password", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let input = alert.textFields?.first?.text ?? ""
            if input == correctPassword {
                // ✅ Correct → remove blur
                self.blurView?.removeFromSuperview()
                self.blurView = nil
            } else {
                // ❌ Wrong password
                self.showWrongPasswordAlert(correctPassword: correctPassword)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            // Suspend app instead of exiting
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }))

        present(alert, animated: true)
    }
    
    func showWrongPasswordAlert(correctPassword: String) {
        let errorAlert = UIAlertController(title: "Wrong Password",
                                           message: "Please try again.",
                                           preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.promptForPassword(correctPassword: correctPassword)
        }))
        present(errorAlert, animated: true)
    }

    // Setup UI
    func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    @objc func handleAppDidBecomeActive(notification: Notification) {
        if let stored = KeychainHelper.standard.readPassword(service: "RegexBlocker", account: "appLock") {
            promptForPassword(correctPassword: stored)
            if let defaults = UserDefaults(suiteName: "group.com.augustin.blocker") {
                defaults.set(true, forKey: "hasPassword")
                defaults.synchronize()
            }
        }else{
            if let defaults = UserDefaults(suiteName: "group.com.augustin.blocker") {
                defaults.set(false, forKey: "hasPassword")  // when removing
                defaults.synchronize()
            }
        }
        loadPatterns()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPatterns()
    }
    
    func updateExtensionPatterns(patterns:[String]) {
        print(patterns)
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.augustin.blocker") {
            let fileURL = containerURL.appendingPathComponent("patterns.json")
            do {
                let json = try JSONSerialization.data(withJSONObject: patterns, options: .prettyPrinted)
                try json.write(to: fileURL, options: .atomic)
            }catch {
                print("Failed to save patterns: ", error)
            }
        }
    }

    func setupButtons() {
        saveButton.setTitle("Save", for: .normal)
        clearButton.setTitle("Clear", for: .normal)

        // Put both buttons inside a horizontal stack
        let buttonStack = UIStackView(arrangedSubviews: [saveButton, clearButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func setupStatusLabel() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textColor = .gray
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            statusLabel.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: clearButton.trailingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor)
        ])
    }

    // MARK: - Load & Save
    func loadPatterns() {
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.augustin.blocker") {
            let fileURL = containerURL.appendingPathComponent("patterns.json")
            if let data = try? Data(contentsOf: fileURL),
               let decoded = try? JSONSerialization.jsonObject(with: data) as? [String] {
                textView.text = decoded.joined(separator: "\n")
                print(decoded)
            }
        }
    }

    @objc func savePatterns() {
        let lines = textView.text
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        updateExtensionPatterns(patterns: lines)
        showStatus("Saved ✓")
    }

    @objc func clearPatterns() {
        textView.text = ""
        updateExtensionPatterns(patterns: [])
        showStatus("Cleared ✓")
    }

    func showStatus(_ message: String) {
        statusLabel.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.statusLabel.text = ""
        }
    }
}
