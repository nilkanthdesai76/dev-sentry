import Foundation

/// Represents a single identified cache file or directory.
public struct ScannedItem: Sendable, Codable, Equatable {
    public let path: String
    public let sizeInBytes: Int64
    public let lastModifiedDate: Date
    public let isImmune: Bool
    public let category: StorageCategory

    public init(
        path: String,
        sizeInBytes: Int64,
        lastModifiedDate: Date,
        isImmune: Bool,
        category: StorageCategory
    ) {
        self.path = path
        self.sizeInBytes = sizeInBytes
        self.lastModifiedDate = lastModifiedDate
        self.isImmune = isImmune
        self.category = category
    }
}

/// Aggregate scan results for a specific category.
public struct CategoryScanResult: Sendable, Codable, Equatable {
    public let category: StorageCategory
    public let totalBytes: Int64
    public let immuneBytes: Int64
    public let itemCount: Int
    public let items: [ScannedItem]

    public var reclaimableBytes: Int64 {
        return max(0, totalBytes - immuneBytes)
    }

    public init(
        category: StorageCategory,
        totalBytes: Int64,
        immuneBytes: Int64,
        itemCount: Int,
        items: [ScannedItem]
    ) {
        self.category = category
        self.totalBytes = totalBytes
        self.immuneBytes = immuneBytes
        self.itemCount = itemCount
        self.items = items
    }
}

/// Live progress update emitted during disk scanning.
public struct ScanProgress: Sendable, Codable {
    public let currentCategory: String
    public let scannedBytes: Int64
    public let filesDiscovered: Int
    public let isComplete: Bool

    public init(
        currentCategory: String,
        scannedBytes: Int64,
        filesDiscovered: Int,
        isComplete: Bool
    ) {
        self.currentCategory = currentCategory
        self.scannedBytes = scannedBytes
        self.filesDiscovered = filesDiscovered
        self.isComplete = isComplete
    }
}

/// Summary report for a complete scan operation.
public struct CompleteScanReport: Sendable, Codable {
    public let timestamp: Date
    public let totalBytes: Int64
    public let reclaimableBytes: Int64
    public let immuneBytes: Int64
    public let totalItems: Int
    public let categories: [CategoryScanResult]

    public init(categories: [CategoryScanResult]) {
        self.timestamp = Date()
        self.categories = categories
        self.totalBytes = categories.reduce(0) { $0 + $1.totalBytes }
        self.immuneBytes = categories.reduce(0) { $0 + $1.immuneBytes }
        self.reclaimableBytes = categories.reduce(0) { $0 + $1.reclaimableBytes }
        self.totalItems = categories.reduce(0) { $0 + $1.itemCount }
    }
}
