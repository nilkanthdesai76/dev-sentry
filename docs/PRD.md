# PRD.md — DevSentry (macOS Developer Disk & Cache Vacuum)

> Product Requirements Document for DevSentry: A blazing-fast, safety-guaranteed developer storage reclaimer that finds and purges gigabytes of forgotten build caches, old simulator runtimes, and orphaned dependencies in seconds.

---

## 🎯 1. Objective & Problem Statement

### The Problem
Active software developers silently lose 40GB–120GB of expensive SSD storage to accumulating build artifacts:
- **Xcode**: Gigabytes of stale `DerivedData`, outdated iOS device support symbols, and old CoreSimulator runtimes.
- **Node.js**: Abandoned `node_modules` folders buried across inactive projects from 6 months ago.
- **Docker**: Dangling build cache layers, dead containers, and orphaned volumes.
- **Package Managers**: SPM `.build` folders, Homebrew cache downloads, CocoaPods, Gradle, and Cargo caches.
Existing cleaner apps are bloated, charge expensive monthly subscriptions, or blindly delete active project build caches, forcing hours of re-indexing.

### The Solution
**DevSentry** is an ultra-fast, developer-first storage engine:
- **2-Second APFS Deep Index**: Traverses developer cache directories using fast low-level Apple File System APIs.
- **24-Hour Active Project Immunity Guardrail**: Automatically detects projects modified in the last 24 hours and locks them against accidental cache eviction.
- **1-Click Granular Reclamation**: Categorizes disk waste cleanly: `Xcode DerivedData (32 GB)`, `Inactive node_modules (18 GB)`, `Old Simulator Runtimes (14 GB)`, `Docker Cache (12 GB)`.
- **APFS Fast Deletion**: Uses APFS clone and snapshot semantics to reclaim storage instantly without UI freezing.

---

## 🗄️ 2. Comprehensive Target Cache Taxonomy

DevSentry targets 12 distinct developer storage waste categories across macOS:

| # | Category Identifier | File System Path | Typical Waste Size | Safe Eviction Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **1** | `xcode.derivedData` | `~/Library/Developer/Xcode/DerivedData` | $15\text{ GB} - 50\text{ GB}$ | Safe to wipe; projects rebuild automatically |
| **2** | `xcode.archives` | `~/Library/Developer/Xcode/Archives` | $10\text{ GB} - 40\text{ GB}$ | Preserves archives $< 90\text{ days}$; purges older |
| **3** | `xcode.deviceSupport` | `~/Library/Developer/Xcode/iOS DeviceSupport` | $8\text{ GB} - 25\text{ GB}$ | Purges symbols for non-current iOS versions |
| **4** | `xcode.simulators` | `~/Library/Developer/CoreSimulator/Devices` | $10\text{ GB} - 30\text{ GB}$ | Runs `xcrun simctl delete unavailable` |
| **5** | `xcode.testCaches` | `~/Library/Caches/com.apple.dt.XCTest` | $2\text{ GB} - 8\text{ GB}$ | Safe to wipe completely |
| **6** | `node.inactiveModules` | Recursive search: `*/node_modules` | $20\text{ GB} - 60\text{ GB}$ | Only purges if project untouched $> 30\text{ days}$ |
| **7** | `npm.cache` | `~/.npm/_cacache` | $2\text{ GB} - 6\text{ GB}$ | Runs `npm cache clean --force` logic |
| **8** | `swift.build` | Recursive search: `*/.build` | $5\text{ GB} - 15\text{ GB}$ | Only purges if project untouched $> 30\text{ days}$ |
| **9** | `cargo.target` | Recursive search: `*/target/debug` | $5\text{ GB} - 20\text{ GB}$ | Cleans debug target builds in inactive Rust repos |
| **10**| `cocoapods.cache` | `~/Library/Caches/CocoaPods` | $3\text{ GB} - 10\text{ GB}$ | Safe to wipe; re-downloads on `pod install` |
| **11**| `homebrew.cache` | `~/Library/Caches/Homebrew` | $4\text{ GB} - 12\text{ GB}$ | Cached `.tar.gz` bottle downloads safe to delete |
| **12**| `docker.prune` | `/var/run/docker.sock` daemon | $10\text{ GB} - 40\text{ GB}$ | Prunes dangling images & build cache via socket |

---

## 🛡️ 3. 24-Hour Active Project Immunity Specification

To prevent wiping build caches for projects the developer is actively working on, DevSentry enforces the **Immunity Rule**:

```
For any project path P:
1. Check file modification timestamps:
   T_mtime = max(mtime of all files in P within depth 2)
2. Check Git last commit timestamp (if P is a git repo):
   T_git = git log -1 --format=%ct P
3. Compute Age:
   Age = min(Now - T_mtime, Now - T_git)

IF Age < 86,400 seconds (24 Hours):
   STATUS = IMMUNE (Locked & Protected)
   -> Excluded from default clean operations
ELSE:
   STATUS = RECLAIMABLE
```

---

## 💻 4. CLI Interface & Flag Specification

```bash
# General Syntax
dev-sentry <command> [options]

# 1. Scan and report storage breakdown without deleting
dev-sentry scan [options]
  --dry-run                     # Preview mode (default: true)
  --json                        # Output raw JSON report for CI/scripts
  --min-size <mb>               # Filter categories smaller than threshold (default: 100MB)

# 2. Reclaim storage
dev-sentry clean [options]
  --all                         # Clean all safe categories
  --category <id>               # Clean specific category (e.g. xcode.derivedData)
  --include-active-projects     # Override 24h immunity lock (requires confirmation)
  --threshold-days <days>       # Inactive threshold for node_modules (default: 30)

# 3. Simulator specific purge
dev-sentry simctl [options]
  --delete-unavailable          # Delete runtimes for removed iOS SDKs
  --erase-all                   # Factory reset all simulator contents
```

---

## 🚫 5. Non-Goals
- No cleaning of personal user data (Photos, Downloads, Desktop, iCloud).
- No background daemon process (runs strictly on-demand).
