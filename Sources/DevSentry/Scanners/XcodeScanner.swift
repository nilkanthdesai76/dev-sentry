import Foundation

public struct XcodeScanner: Sendable {
    public static func scanDerivedData() -> CategoryScanResult {
        guard let path = StorageCategory.xcodeDerivedData.defaultPath,
              FileManager.default.fileExists(atPath: path) else {
            return CategoryScanResult(
                category: .xcodeDerivedData,
                totalBytes: 0,
                immuneBytes: 0,
                itemCount: 0,
                items: []
            )
        }

        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: path) else {
            return CategoryScanResult(
                category: .xcodeDerivedData,
                totalBytes: 0,
                immuneBytes: 0,
                itemCount: 0,
                items: []
            )
        }

        var items: [ScannedItem] = []
        var totalBytes: Int64 = 0
        var immuneBytes: Int64 = 0

        for name in contents where !name.hasPrefix(".") {
            let itemPath = (path as NSString).appendingPathComponent(name)
            let size = APFSDirectoryCleaner.calculateSize(of: itemPath)
            let isImmune = ImmunityManager.isImmune(path: itemPath)
            let modDate = (try? fm.attributesOfItem(atPath: itemPath)[.modificationDate] as? Date) ?? Date()

            let item = ScannedItem(
                path: itemPath,
                sizeInBytes: size,
                lastModifiedDate: modDate,
                isImmune: isImmune,
                category: .xcodeDerivedData
            )
            items.append(item)
            totalBytes += size
            if isImmune {
                immuneBytes += size
            }
        }

        return CategoryScanResult(
            category: .xcodeDerivedData,
            totalBytes: totalBytes,
            immuneBytes: immuneBytes,
            itemCount: items.count,
            items: items
        )
    }

    public static func scanArchives() -> CategoryScanResult {
        guard let path = StorageCategory.xcodeArchives.defaultPath,
              FileManager.default.fileExists(atPath: path) else {
            return CategoryScanResult(category: .xcodeArchives, totalBytes: 0, immuneBytes: 0, itemCount: 0, items: [])
        }

        let fm = FileManager.default
        let ninetyDaysAgo = Date().addingTimeInterval(-90.0 * 86400.0)
        var items: [ScannedItem] = []
        var totalBytes: Int64 = 0
        var immuneBytes: Int64 = 0

        if let dates = try? fm.contentsOfDirectory(atPath: path) {
            for d in dates where !d.hasPrefix(".") {
                let sub = (path as NSString).appendingPathComponent(d)
                if let archives = try? fm.contentsOfDirectory(atPath: sub) {
                    for a in archives where a.hasSuffix(".xcarchive") {
                        let arcPath = (sub as NSString).appendingPathComponent(a)
                        let size = APFSDirectoryCleaner.calculateSize(of: arcPath)
                        let modDate = (try? fm.attributesOfItem(atPath: arcPath)[.modificationDate] as? Date) ?? Date()
                        // Archives < 90 days are immune
                        let isImmune = modDate > ninetyDaysAgo
                        let item = ScannedItem(
                            path: arcPath,
                            sizeInBytes: size,
                            lastModifiedDate: modDate,
                            isImmune: isImmune,
                            category: .xcodeArchives
                        )
                        items.append(item)
                        totalBytes += size
                        if isImmune { immuneBytes += size }
                    }
                }
            }
        }

        return CategoryScanResult(
            category: .xcodeArchives,
            totalBytes: totalBytes,
            immuneBytes: immuneBytes,
            itemCount: items.count,
            items: items
        )
    }

    public static func scanDeviceSupport() -> CategoryScanResult {
        guard let path = StorageCategory.xcodeDeviceSupport.defaultPath,
              FileManager.default.fileExists(atPath: path) else {
            return CategoryScanResult(category: .xcodeDeviceSupport, totalBytes: 0, immuneBytes: 0, itemCount: 0, items: [])
        }

        let fm = FileManager.default
        var items: [ScannedItem] = []
        var totalBytes: Int64 = 0

        if let entries = try? fm.contentsOfDirectory(atPath: path) {
            for entry in entries where !entry.hasPrefix(".") {
                let itemPath = (path as NSString).appendingPathComponent(entry)
                let size = APFSDirectoryCleaner.calculateSize(of: itemPath)
                let modDate = (try? fm.attributesOfItem(atPath: itemPath)[.modificationDate] as? Date) ?? Date()
                let item = ScannedItem(
                    path: itemPath,
                    sizeInBytes: size,
                    lastModifiedDate: modDate,
                    isImmune: false,
                    category: .xcodeDeviceSupport
                )
                items.append(item)
                totalBytes += size
            }
        }

        return CategoryScanResult(
            category: .xcodeDeviceSupport,
            totalBytes: totalBytes,
            immuneBytes: 0,
            itemCount: items.count,
            items: items
        )
    }

    public static func scanTestCaches() -> CategoryScanResult {
        guard let path = StorageCategory.xcodeTestCaches.defaultPath,
              FileManager.default.fileExists(atPath: path) else {
            return CategoryScanResult(category: .xcodeTestCaches, totalBytes: 0, immuneBytes: 0, itemCount: 0, items: [])
        }

        let size = APFSDirectoryCleaner.calculateSize(of: path)
        let item = ScannedItem(
            path: path,
            sizeInBytes: size,
            lastModifiedDate: Date(),
            isImmune: false,
            category: .xcodeTestCaches
        )

        return CategoryScanResult(
            category: .xcodeTestCaches,
            totalBytes: size,
            immuneBytes: 0,
            itemCount: size > 0 ? 1 : 0,
            items: size > 0 ? [item] : []
        )
    }
}
