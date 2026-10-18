import Foundation

/// 12 distinct developer storage waste categories.
public enum StorageCategory: String, CaseIterable, Sendable, Codable {
    case xcodeDerivedData = "xcode.derivedData"
    case xcodeArchives = "xcode.archives"
    case xcodeDeviceSupport = "xcode.deviceSupport"
    case xcodeSimulators = "xcode.simulators"
    case xcodeTestCaches = "xcode.testCaches"
    case nodeInactiveModules = "node.inactiveModules"
    case npmCache = "npm.cache"
    case swiftBuild = "swift.build"
    case cargoTarget = "cargo.target"
    case cocoapodsCache = "cocoapods.cache"
    case homebrewCache = "homebrew.cache"
    case dockerPrune = "docker.prune"

    public var displayName: String {
        switch self {
        case .xcodeDerivedData: return "Xcode DerivedData"
        case .xcodeArchives: return "Xcode Archives (>90 days)"
        case .xcodeDeviceSupport: return "iOS Device Support Symbols"
        case .xcodeSimulators: return "CoreSimulator Devices & Caches"
        case .xcodeTestCaches: return "Xcode Test Caches"
        case .nodeInactiveModules: return "Inactive node_modules (>30 days)"
        case .npmCache: return "NPM Download Cache"
        case .swiftBuild: return "Swift Package Build Folders (.build)"
        case .cargoTarget: return "Cargo Rust Debug Targets (target/debug)"
        case .cocoapodsCache: return "CocoaPods Cache"
        case .homebrewCache: return "Homebrew Bottle Caches"
        case .dockerPrune: return "Docker Dangling Build Layers"
        }
    }

    public var defaultPath: String? {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        switch self {
        case .xcodeDerivedData:
            return "\(home)/Library/Developer/Xcode/DerivedData"
        case .xcodeArchives:
            return "\(home)/Library/Developer/Xcode/Archives"
        case .xcodeDeviceSupport:
            return "\(home)/Library/Developer/Xcode/iOS DeviceSupport"
        case .xcodeSimulators:
            return "\(home)/Library/Developer/CoreSimulator/Devices"
        case .xcodeTestCaches:
            return "\(home)/Library/Caches/com.apple.dt.XCTest"
        case .npmCache:
            return "\(home)/.npm/_cacache"
        case .cocoapodsCache:
            return "\(home)/Library/Caches/CocoaPods"
        case .homebrewCache:
            return "\(home)/Library/Caches/Homebrew"
        case .nodeInactiveModules, .swiftBuild, .cargoTarget, .dockerPrune:
            return nil // Recursive or socket based
        }
    }

    public var isSafeByDefault: Bool {
        switch self {
        case .xcodeDerivedData, .xcodeTestCaches, .npmCache, .cocoapodsCache, .homebrewCache:
            return true
        default:
            return false
        }
    }
}
