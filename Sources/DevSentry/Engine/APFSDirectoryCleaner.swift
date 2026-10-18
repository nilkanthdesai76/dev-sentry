import Foundation

/// Fast asynchronous directory reclaimer optimized for APFS.
/// Moves directories to an ephemeral temporary scratch folder atomically,
/// then unlinks them asynchronously in background threads.
public actor APFSDirectoryCleaner {
    private let fileManager = FileManager.default

    public init() {}

    /// Purges a target path safely with security validation and instant APFS relocation.
    /// Returns the number of bytes reclaimed.
    public func cleanPath(
        _ path: String,
        dryRun: Bool = false
    ) async throws -> Int64 {
        // 1. Enforce strict system safety guardrails
        try ImmunityManager.validateDeletionPath(path)

        guard fileManager.fileExists(atPath: path) else {
            return 0
        }

        // 2. Calculate directory size before removal
        let size = Self.calculateSize(of: path)

        if dryRun {
            return size
        }

        // 3. APFS Fast Atomic Relocation
        let tempDir = NSTemporaryDirectory()
        let uniqueName = "dev_sentry_purge_\(UUID().uuidString)"
        let scratchPath = (tempDir as NSString).appendingPathComponent(uniqueName)

        // Try fast atomic rename to scratch directory
        let renameResult = rename(path, scratchPath)
        if renameResult == 0 {
            // Atomic rename succeeded; unlink asynchronously in background
            Task.detached(priority: .background) {
                try? FileManager.default.removeItem(atPath: scratchPath)
            }
        } else {
            // Direct remove fallback
            try fileManager.removeItem(atPath: path)
        }

        return size
    }

    /// Recursively calculates total disk space allocated by a directory.
    public static func calculateSize(of path: String) -> Int64 {
        var total: Int64 = 0
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) else { return 0 }

        if let enumerator = fm.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .fileSizeKey],
            options: []
        ) {
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey, .fileSizeKey]) {
                    let fileSize = resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? resourceValues.fileSize ?? 0
                    total += Int64(fileSize)
                }
            }
        }

        return total
    }
}
