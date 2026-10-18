import Foundation
import DevSentry

@main
struct DevSentryCLI {
    static func main() async {
        let args = CommandLine.arguments

        let isJson = args.contains("--json")
        let isDryRun = args.contains("--dry-run") || !args.contains("clean")
        let includeActive = args.contains("--include-active-projects")

        if !isJson {
            print("\u{001B}[2J\u{001B}[H", terminator: "") // Clear screen
            print("""
            \u{001B}[1;35m=========================================================================\u{001B}[0m
            \u{001B}[1;32m         🛡️  DevSentry — macOS Developer Disk & Cache Vacuum             \u{001B}[0m
            \u{001B}[1;35m=========================================================================\u{001B}[0m
            High-Speed APFS Storage Reclaimer • 24-Hour Active Project Immunity Guard
            
            """)
        }

        let coordinator = StorageScanCoordinator()

        if !isJson {
            print("\u{001B}[1;33m🔍 Scanning macOS developer build caches and runtime stores...\u{001B}[0m\n")
        }

        let report = await coordinator.scanAll(projectSearchRoot: FileManager.default.currentDirectoryPath) { progress in
            if !isJson && !progress.isComplete {
                print("  ⏳ Scanning: \u{001B}[1;34m\(progress.currentCategory)\u{001B}[0m...")
            }
        }

        if isJson {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            if let data = try? encoder.encode(report), let jsonStr = String(data: data, encoding: .utf8) {
                print(jsonStr)
            }
            return
        }

        print("\n\u{001B}[1;36m+------------------------------------+------------+------------+-------+\u{001B}[0m")
        print("\u{001B}[1;36m| Category                           | Reclaim    | Protected  | Items |\u{001B}[0m")
        print("\u{001B}[1;36m+------------------------------------+------------+------------+-------+\u{001B}[0m")

        for cat in report.categories {
            let name = cat.category.displayName.prefix(34).padding(toLength: 34, withPad: " ", startingAt: 0)
            let reclaimStr = ByteFormatter.format(cat.reclaimableBytes).padding(toLength: 10, withPad: " ", startingAt: 0)
            let immuneStr = ByteFormatter.format(cat.immuneBytes).padding(toLength: 10, withPad: " ", startingAt: 0)
            let countStr = String(cat.itemCount).padding(toLength: 5, withPad: " ", startingAt: 0)

            print("| \(name) | \(reclaimStr) | \(immuneStr) | \(countStr) |")
        }

        print("\u{001B}[1;36m+------------------------------------+------------+------------+-------+\u{001B}[0m")
        print("\u{001B}[1;32m  Total Detected Storage:      \(ByteFormatter.format(report.totalBytes))\u{001B}[0m")
        print("\u{001B}[1;33m  Safe Reclaimable:            \(ByteFormatter.format(report.reclaimableBytes))\u{001B}[0m")
        print("\u{001B}[1;34m  24h Immunity Protected:      \(ByteFormatter.format(report.immuneBytes))\u{001B}[0m")
        print("\u{001B}[1;36m+------------------------------------+------------+------------+-------+\u{001B}[0m\n")

        if args.contains("clean") {
            print("\u{001B}[1;31m⚡ Executing safe reclamation (Dry Run: \(isDryRun))...\u{001B}[0m")
            let result = await coordinator.clean(
                report: report,
                includeImmune: includeActive,
                dryRun: isDryRun
            )
            print("\n  ✅ Reclaimed \(ByteFormatter.format(result.reclaimedBytes)) across \(result.itemsPurged) target folders.")
        } else {
            print("💡 Run with \u{001B}[1;32mdev-sentry clean\u{001B}[0m to reclaim storage or \u{001B}[1;32m--json\u{001B}[0m for structured output.\n")
        }
    }
}
