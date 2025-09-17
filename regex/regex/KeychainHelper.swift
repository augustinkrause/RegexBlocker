import UIKit
import Security

class KeychainHelper {
    static let standard = KeychainHelper()

    func save(password: String, service: String, account: String) {
        let data = password.data(using: .utf8)!

        // Remove any existing password
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)

        // Add new password
        let attributes: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                         kSecAttrService as String: service,
                                         kSecAttrAccount as String: account,
                                         kSecValueData as String: data]
        SecItemAdd(attributes as CFDictionary, nil)
    }

    func readPassword(service: String, account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]

        var item: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &item)

        if let data = item as? Data, let password = String(data: data, encoding: .utf8) {
            return password
        }
        return nil
    }
    
    func deletePassword(service: String, account: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        SecItemDelete(query as CFDictionary)
    }
}
