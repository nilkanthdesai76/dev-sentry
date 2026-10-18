import Foundation

/// Fast human-readable byte formatter.
public struct ByteFormatter: Sendable {
    public static func format(_ bytes: Int64, decimals: Int = 2) -> String {
        guard bytes > 0 else { return "0 B" }

        let units = ["B", "KB", "MB", "GB", "TB", "PB"]
        var size = Double(bytes)
        var unitIndex = 0

        while size >= 1024.0 && unitIndex < units.count - 1 {
            size /= 1024.0
            unitIndex += 1
        }

        if unitIndex == 0 {
            return "\(bytes) B"
        } else {
            return String(format: "%.\(decimals)f \(units[unitIndex])", size)
        }
    }
}
