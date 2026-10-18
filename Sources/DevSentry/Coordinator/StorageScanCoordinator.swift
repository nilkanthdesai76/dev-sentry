import Foundation

/// Central actor coordinating multi-threaded category scans with live AsyncStream progress updates.
public actor StorageScanCoordinator {
    public init() {}

    /// Executes full scan across all standard developer categories.
    public func scanAll(
        projectSearchRoot: String? = nil,
        onProgress: (@Sendable (ScanProgress) -> Void)? = nil
    ) async -> CompleteScanReport {
        var results: [CategoryScanResult] = []
        var totalDiscoveredBytes: Int64 = 0
        var totalDiscoveredFiles: Int = 0

        // 1. Xcode DerivedData
        onProgress?(ScanProgress(
            currentCategory: StorageCategory.xcodeDerivedData.displayName,
            scannedBytes: totalDiscoveredBytes,
            filesDiscovered: totalDiscoveredFiles,
            isComplete: false
        ))
        let derived = XcodeScanner.scanDerivedData()
        results.append(derived)
        totalDiscoveredBytes += derived.totalBytes
        totalDiscoveredFiles += derived.itemCount

        // 2. Xcode Archives
        onProgress?(ScanProgress(
            currentCategory: StorageCategory.xcodeArchives.displayName,
            scannedBytes: totalDiscoveredBytes,
            filesDiscovered: totalDiscoveredFiles,
            isComplete: false
        ))
        let archives = XcodeScanner.scanArchives()
        results.append(archives)
        totalDiscoveredBytes += archives.totalBytes
        totalDiscoveredFiles += archives.itemCount

        // 3. iOS Device Support
        onProgress?(ScanProgress(
            currentCategory: StorageCategory.xcodeDeviceSupport.displayName,
            scannedBytes: totalDiscoveredBytes,
            filesDiscovered: totalDiscoveredFiles,
            isComplete: false
        ))
        let devSupport = XcodeScanner.scanDeviceSupport()
        results.append(devSupport)
        totalDiscoveredBytes += devSupport.totalBytes
        totalDiscoveredFiles += devSupport.itemCount

        // 4. Xcode Test Caches
        onProgress?(ScanProgress(
            currentCategory: StorageCategory.xcodeTestCaches.displayName,
            scannedBytes: totalDiscoveredBytes,
            filesDiscovered: totalDiscoveredFiles,
            isComplete: false
        ))
        let testCaches = XcodeScanner.scanTestCaches()
        results.append(testCaches)
        totalDiscoveredBytes += testCaches.totalBytes
        totalDiscoveredFiles += testCaches.itemCount

        // 5. Package Caches (Homebrew, CocoaPods, NPM)
        onProgress?(ScanProgress(
            currentCategory: "Package Caches",
            scannedBytes: totalDiscoveredBytes,
            filesDiscovered: totalDiscoveredFiles,
            isComplete: false
        ))
        let brew = PackageCacheScanner.scanHomebrew()
        results.append(brew)
        totalDiscoveredBytes += brew.totalBytes
        totalDiscoveredFiles += brew.itemCount

        let pods = PackageCacheScanner.scanCocoaPods()
        results.append(pods)
        totalDiscoveredBytes += pods.totalBytes
        totalDiscoveredFiles += pods.itemCount

        let npm = PackageCacheScanner.scanNpmCache()
        results.append(npm)
        totalDiscoveredBytes += npm.totalBytes
        totalDiscoveredFiles += npm.itemCount

        // 6. Optional Recursive Project Scan
        if let root = projectSearchRoot, FileManager.default.fileExists(atPath: root) {
            onProgress?(ScanProgress(
                currentCategory: "Project node_modules",
                scannedBytes: totalDiscoveredBytes,
                filesDiscovered: totalDiscoveredFiles,
                isComplete: false
            ))
            let node = ProjectBuildScanner.scanProjectDirectories(
                rootPath: root,
                targetFolderName: "node_modules",
                category: .nodeInactiveModules
            )
            results.append(node)
            totalDiscoveredBytes += node.totalBytes
            totalDiscoveredFiles += node.itemCount

            let spm = ProjectBuildScanner.scanProjectDirectories(
                rootPath: root,
                targetFolderName: ".build",
                category: .swiftBuild
            )
            results.append(spm)
            totalDiscoveredBytes += spm.totalBytes
            totalDiscoveredFiles += spm.itemCount
        }

        onProgress?(ScanProgress(
            currentCategory: "Complete",
            scannedBytes: totalDiscoveredBytes,
            filesDiscovered: totalDiscoveredFiles,
            isComplete: true
        ))

        return CompleteScanReport(categories: results)
    }

    /// Cleans items from a scan report adhering to immunity rules.
    public func clean(
        report: CompleteScanReport,
        categoryFilter: StorageCategory? = nil,
        includeImmune: Bool = false,
        dryRun: Bool = false
    ) async -> (reclaimedBytes: Int64, itemsPurged: Int) {
        let cleaner = APFSDirectoryCleaner()
        var totalReclaimed: Int64 = 0
        var purgedCount = 0

        for catResult in report.categories {
            if let filter = categoryFilter, catResult.category != filter {
                continue
            }

            for item in catResult.items {
                if item.isImmune && !includeImmune {
                    continue
                }

                if let reclaimed = try? await cleaner.cleanPath(item.path, dryRun: dryRun) {
                    totalReclaimed += reclaimed
                    purgedCount += 1
                }
            }
        }

        return (totalReclaimed, purgedCount)
    }
}
