import Foundation

public struct PackageCacheScanner: Sendable {
    public static func scanHomebrew() -> CategoryScanResult {
        return scanFixedDirectory(category: .homebrewCache)
    }

    public static func scanCocoaPods() -> CategoryScanResult {
        return scanFixedDirectory(category: .cocoapodsCache)
    }

    public static func scanNpmCache() -> CategoryScanResult {
        return scanFixedDirectory(category: .npmCache)
    }

    private static func scanFixedDirectory(category: StorageCategory) -> CategoryScanResult {
        guard let path = category.defaultPath,
              FileManager.default.fileExists(atPath: path) else {
            return CategoryScanResult(category: category, totalBytes: 0, immuneBytes: 0, itemCount: 0, items: [])
        }

        let size = APFSDirectoryCleaner.calculateSize(of: path)
        let item = ScannedItem(
            path: path,
            sizeInBytes: size,
            lastModifiedDate: Date(),
            isImmune: false,
            category: category
        )

        return CategoryScanResult(
            category: category,
            totalBytes: size,
            immuneBytes: 0,
            itemCount: size > 0 ? 1 : 0,
            items: size > 0 ? [item] : []
        )
    }
}
