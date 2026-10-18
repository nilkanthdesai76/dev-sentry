import XCTest
@testable import DevSentry

final class ImmunityManagerTests: XCTestCase {

    func testImmunityWithin24Hours() {
        let tempDir = NSTemporaryDirectory()
        let testFolder = (tempDir as NSString).appendingPathComponent("dev_sentry_test_active_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(atPath: testFolder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: testFolder) }

        // A freshly created directory has modDate = now (<24 hours)
        let isImmune = ImmunityManager.isImmune(path: testFolder)
        XCTAssertTrue(isImmune, "Freshly modified folder within 24h must be immune")
    }

    func testAgingCalculations() {
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600)
        let twentyFiveHoursAgo = now.addingTimeInterval(-25 * 3600)
        let fortyFiveDaysAgo = now.addingTimeInterval(-45 * 86400)

        // Verify time arithmetic
        XCTAssertLessThan(now.timeIntervalSince(oneHourAgo), ImmunityManager.oneDayInSeconds)
        XCTAssertGreaterThan(now.timeIntervalSince(twentyFiveHoursAgo), ImmunityManager.oneDayInSeconds)
        XCTAssertGreaterThan(now.timeIntervalSince(fortyFiveDaysAgo), ImmunityManager.thirtyDaysInSeconds)
    }

    func testSecurityGuardrailsRejectSystemPaths() {
        XCTAssertThrowsError(try ImmunityManager.validateDeletionPath("/")) { error in
            guard case SecurityViolationError.protectedSystemPath = error else {
                XCTFail("Expected protectedSystemPath error, got \(error)")
                return
            }
        }

        XCTAssertThrowsError(try ImmunityManager.validateDeletionPath("/System"))
        XCTAssertThrowsError(try ImmunityManager.validateDeletionPath("/Library"))
        XCTAssertThrowsError(try ImmunityManager.validateDeletionPath("/Applications"))
        XCTAssertThrowsError(try ImmunityManager.validateDeletionPath("/Users"))

        // User home itself must not be deleted
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        XCTAssertThrowsError(try ImmunityManager.validateDeletionPath(home))
    }
}
