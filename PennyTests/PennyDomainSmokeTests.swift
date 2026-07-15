import XCTest
@testable import Penny

final class PennyDomainSmokeTests: XCTestCase {
    func testNormalizeMerchantSmoke() {
        let normalized = TransactionRulesEngine.normalizeMerchant("PAYPAL *NETFLIX 123")
        XCTAssertEqual(normalized, "Netflix")
    }
}
