import UIKit

class HelpViewController: UIViewController {

    let textView = UITextView()
    let linkButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help"
        view.backgroundColor = .systemBackground

        setupTextView()
        setupLinkButton()
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .clear

        textView.text = """
        ❕This extension implements blocks based on matching JavaScript Regular Expressions (Regexes).
        Below you will find some basic information on how to use them.
        
        📘 JavaScript Regex Basics

        .   → any single character
        *   → 0 or more repetitions
        +   → 1 or more repetitions
        ?   → 0 or 1 (optional)
        ^   → start of string
        $   → end of string
        [abc] → any one of a, b, or c
        [^abc] → any character except a, b, or c
        \\d  → any digit (0–9)
        \\w  → any word character (letter, digit, underscore)
        \\s  → any whitespace character

        Escaping:
        Use double backslashes in Swift strings, e.g. "\\." matches a literal dot.

        Flags:
        /regex/i   → case-insensitive
        /regex/g   → global (all matches)
        /regex/m   → multiline mode

        👉 Example:
        /test.*/i matches "TEST123", "testcase", etc.
        
        🔧 How to Activate the Extension (iOS)

            1. Open the **Settings app**.
            2. Scroll down and select **Safari**.
            3. Tap **Extensions**.
            4. Find **RegexBlocker** in the list.
            5. Enable the extension by toggling it on.
            6. (Optional) Under “All Websites”, allow RegexBlocker access if needed.

        Once activated, RegexBlocker will run in Safari and apply your regex patterns.
        """

        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60) // leave space for button
        ])
    }

    private func setupLinkButton() {
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.setTitle("Learn more on MDN", for: .normal)
        linkButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
        view.addSubview(linkButton)

        NSLayoutConstraint.activate([
            linkButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            linkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func openLink() {
        if let url = URL(string: "https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_expressions") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
