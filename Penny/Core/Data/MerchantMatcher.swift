import Foundation

final class MerchantMatcher {
    private let map: [String: String]
    private let keysByLengthDesc: [String]

    init() {
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
            guard key.count >= 4 else { continue }
            if containsWholePhrase(key, in: s) {
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

        let noisePatterns = [
            "pending ",
            "debit card purchase ",
            "card purchase ",
            "purchase authorized on ",
            "recurring purchase ",
            "pos withdrawal ",
            "pos purchase ",
            "checkcard ",
            "withdrawal ",
            "payment to ",
            "payment ",
            "visa "
        ]

        for pattern in noisePatterns where normalized.hasPrefix(pattern) {
            normalized.removeFirst(pattern.count)
            break
        }

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

    private func containsWholePhrase(_ phrase: String, in text: String) -> Bool {
        if text == phrase {
            return true
        }

        return text.contains(" \(phrase) ")
            || text.hasPrefix("\(phrase) ")
            || text.hasSuffix(" \(phrase)")
    }
}
