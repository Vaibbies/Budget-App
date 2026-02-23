import Foundation

final class MerchantMatcher {
    static let shared = MerchantMatcher()

    private let map: [String: String]
    private let keysByLengthDesc: [String]

    private init() {
        self.map = Self.loadMapFromBundle(named: "merchant_domains_pro") ?? [:]
        self.keysByLengthDesc = map.keys.sorted { $0.count > $1.count }
    }

    func domain(for raw: String) -> String? {
        let s = normalize(raw)
        guard !s.isEmpty else { return nil }

        if let direct = map[s] {
            return direct
        }

        for key in keysByLengthDesc {
            if s.contains(key) {
                return map[key]
            }
        }

        return nil
    }

    private static func loadMapFromBundle(named name: String) -> [String: String]? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            #if DEBUG
            print("MerchantMatcher: missing \(name).json in bundle")
            #endif
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            #if DEBUG
            print("MerchantMatcher: failed to decode \(name).json - \(error)")
            #endif
            return nil
        }
    }

    private func normalize(_ input: String) -> String {
        var normalized = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        let charsToSpace = CharacterSet(charactersIn: "'’`.,:;|/\\-_()[]{}*&^%$#@!~+=\"")
        let transformed = normalized.unicodeScalars.map { scalar in
            charsToSpace.contains(scalar) ? " " : String(Character(scalar))
        }
        normalized = transformed.joined()

        while normalized.contains("  ") {
            normalized = normalized.replacingOccurrences(of: "  ", with: " ")
        }

        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
