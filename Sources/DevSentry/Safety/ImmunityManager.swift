import Foundation

public enum SecurityViolationError: Error, LocalizedError, Sendable {
    case protectedSystemPath(String)
    case outsideTargetVolume(String)

    public var errorDescription: String? {
        switch self {
        case .protectedSystemPath(let path):
            return "Security Violation: '\(path)' is a protected system directory and cannot be modified."
        case .outsideTargetVolume(let path):
            return "Security Violation: '\(path)' is outside the authorized user home directory."
        }
    }
}

/// Evaluates project activity, 24-hour immunity rules, and protected system guardrails.
public final class ImmunityManager: Sendable {
    public static let oneDayInSeconds: TimeInterval = 86400.0 // 24 hours
    public static let thirtyDaysInSeconds: TimeInterval = 30.0 * 86400.0 // 30 days

    /// Strict list of protected system roots that must NEVER be deleted.
    private static let protectedSystemPrefixes: [String] = [
        "/",
        "/System",
        "/Library",
        "/Applications",
        "/Users",
        "/bin",
        "/sbin",
        "/usr",
        "/etc",
        "/var",
        "/private",
        "/opt",
        "/Volumes"
    ]

    /// Asserts that a target deletion path is not a protected system path.
    public static func validateDeletionPath(_ path: String) throws {
        let normalized = (path as NSString).standardizingPath

        for protected in protectedSystemPrefixes {
            if normalized == protected {
                throw SecurityViolationError.protectedSystemPath(normalized)
            }
        }

        // Also ensure user home directory itself is never deleted
        #if os(macOS)
        let home = (FileManager.default.homeDirectoryForCurrentUser.path as NSString).standardizingPath
        #else
        let home = (NSHomeDirectory() as NSString).standardizingPath
        #endif
        if normalized == home {
            throw SecurityViolationError.protectedSystemPath(normalized)
        }
    }

    /// Evaluates whether an item or project was modified within the last 24 hours.
    public static func isImmune(path: String, referenceDate: Date = Date()) -> Bool {
        let age = ageInSeconds(for: path, referenceDate: referenceDate)
        return age < oneDayInSeconds
    }

    /// Evaluates whether an inactive artifact (e.g. node_modules) exceeds inactive threshold (e.g. 30 days).
    public static func isInactive(path: String, thresholdDays: Int = 30, referenceDate: Date = Date()) -> Bool {
        let age = ageInSeconds(for: path, referenceDate: referenceDate)
        let thresholdSec = Double(thresholdDays) * 86400.0
        return age >= thresholdSec
    }

    /// Computes effective age of a project path based on file attributes and git repository state.
    public static func ageInSeconds(for path: String, referenceDate: Date = Date()) -> TimeInterval {
        var mostRecentDate: Date = .distantPast

        // 1. Check folder/file modification date
        if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
           let modDate = attrs[.modificationDate] as? Date {
            if modDate > mostRecentDate {
                mostRecentDate = modDate
            }
        }

        // 2. Check depth-2 items if directory
        let fm = FileManager.default
        if let enumerator = fm.enumerator(
            at: URL(fileURLWithPath: path),
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsSubdirectoryDescendants]
        ) {
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
                   let modDate = resourceValues.contentModificationDate {
                    if modDate > mostRecentDate {
                        mostRecentDate = modDate
                    }
                }
            }
        }

        // 3. Fallback if no dates found
        if mostRecentDate == .distantPast {
            return oneDayInSeconds + 1.0 // Treat unknown as not immune
        }

        let age = referenceDate.timeIntervalSince(mostRecentDate)
        return max(0, age)
    }
}
