import Foundation

struct SharedDefaults {
    static let suiteName = "group.com.augustin.blocker"
    static let key = "regexPatterns"

    static var defaults: UserDefaults? {
        return UserDefaults(suiteName: suiteName)
    }

    static func save(patterns: [String]) {
        defaults?.set(patterns, forKey: key)
    }

    static func load() -> [String] {
        return defaults?.stringArray(forKey: key) ?? []
    }
}
