import Foundation

public struct ProjectBuildScanner: Sendable {
    public static func scanProjectDirectories(
        rootPath: String,
        targetFolderName: String,
        category: StorageCategory,
        maxDepth: Int = 4,
        inactiveThresholdDays: Int = 30
    ) -> CategoryScanResult {
        let fm = FileManager.default
        guard fm.fileExists(atPath: rootPath) else {
            return CategoryScanResult(category: category, totalBytes: 0, immuneBytes: 0, itemCount: 0, items: [])
        }

        var items: [ScannedItem] = []
        var totalBytes: Int64 = 0
        var immuneBytes: Int64 = 0

        func traverse(currentURL: URL, currentDepth: Int) {
            guard currentDepth <= maxDepth else { return }

            guard let contents = try? fm.contentsOfDirectory(
                at: currentURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { return }

            for url in contents {
                var isDir: ObjCBool = false
                if fm.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                    if url.lastPathComponent == targetFolderName {
                        // Found build cache folder
                        let itemPath = url.path
                        let projectPath = url.deletingLastPathComponent().path
                        let isImmune = ImmunityManager.isImmune(path: projectPath)
                        let isInactive = ImmunityManager.isInactive(path: projectPath, thresholdDays: inactiveThresholdDays)
                        let size = APFSDirectoryCleaner.calculateSize(of: itemPath)

                        let finalImmune = isImmune || !isInactive
                        let modDate = (try? fm.attributesOfItem(atPath: itemPath)[.modificationDate] as? Date) ?? Date()

                        let item = ScannedItem(
                            path: itemPath,
                            sizeInBytes: size,
                            lastModifiedDate: modDate,
                            isImmune: finalImmune,
                            category: category
                        )
                        items.append(item)
                        totalBytes += size
                        if finalImmune { immuneBytes += size }
                    } else {
                        // Avoid recursing into other dependencies
                        if url.lastPathComponent != "node_modules" &&
                           url.lastPathComponent != ".build" &&
                           url.lastPathComponent != "Pods" &&
                           url.lastPathComponent != "target" {
                            traverse(currentURL: url, currentDepth: currentDepth + 1)
                        }
                    }
                }
            }
        }

        traverse(currentURL: URL(fileURLWithPath: rootPath), currentDepth: 0)

        return CategoryScanResult(
            category: category,
            totalBytes: totalBytes,
            immuneBytes: immuneBytes,
            itemCount: items.count,
            items: items
        )
    }
}
