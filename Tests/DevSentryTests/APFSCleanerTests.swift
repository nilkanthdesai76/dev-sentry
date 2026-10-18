import XCTest
@testable import DevSentry

final class APFSCleanerTests: XCTestCase {

    func testSandboxDeletion() async throws {
        let tempDir = NSTemporaryDirectory()
        let testSandbox = (tempDir as NSString).appendingPathComponent("dev_sentry_sandbox_\(UUID().uuidString)")
        let subFile = (testSandbox as NSString).appendingPathComponent("sample.txt")

        try FileManager.default.createDirectory(atPath: testSandbox, withIntermediateDirectories: true)
        let sampleData = "Sample data for DevSentry APFS purge test".data(using: .utf8)!
        try sampleData.write(to: URL(fileURLWithPath: subFile))

        let cleaner = APFSDirectoryCleaner()

        // 1. Dry run test
        let dryRunReclaimed = try await cleaner.cleanPath(testSandbox, dryRun: true)
        XCTAssertGreaterThan(dryRunReclaimed, 0)
        XCTAssertTrue(FileManager.default.fileExists(atPath: testSandbox))

        // 2. Real clean test
        let realReclaimed = try await cleaner.cleanPath(testSandbox, dryRun: false)
        XCTAssertGreaterThan(realReclaimed, 0)

        // Path should disappear immediately
        XCTAssertFalse(FileManager.default.fileExists(atPath: testSandbox))
    }
}
