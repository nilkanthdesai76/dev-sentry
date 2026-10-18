import XCTest
@testable import DevSentry

final class ByteFormatterTests: XCTestCase {

    func testByteBoundaries() {
        XCTAssertEqual(ByteFormatter.format(0), "0 B")
        XCTAssertEqual(ByteFormatter.format(-10), "0 B")
        XCTAssertEqual(ByteFormatter.format(1023), "1023 B")
        XCTAssertEqual(ByteFormatter.format(1024), "1.00 KB")
        XCTAssertEqual(ByteFormatter.format(1024 * 1024), "1.00 MB")
        XCTAssertEqual(ByteFormatter.format(1024 * 1024 * 1024), "1.00 GB")
        XCTAssertEqual(ByteFormatter.format(Int64(1024) * 1024 * 1024 * 1024), "1.00 TB")
    }

    func testCustomDecimalPrecision() {
        let oneAndHalfMB: Int64 = Int64(1.5 * 1024.0 * 1024.0)
        XCTAssertEqual(ByteFormatter.format(oneAndHalfMB, decimals: 1), "1.5 MB")
    }
}
