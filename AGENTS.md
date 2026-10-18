# AGENTS.md — DevSentry Operational Manual

> Ground-truth invariants, build/test commands, and rules for AI coding assistants working in `dev-sentry`.

---

## 🧭 1. Project Overview
- **Project Name**: `dev-sentry`
- **Core Purpose**: High-speed developer disk and cache vacuum for macOS.
- **Primary Tech Stack**: Swift 6, APFS, SwiftUI, AppKit.
- **Deployment Targets**: macOS 14.0+ (Sonoma, Sequoia).

---

## ⚡ 2. Verified Execution Commands

```bash
# Build Swift package
swift build

# Run unit tests
swift test

# Run single targeted test
swift test --filter ImmunityManagerTests

# Build with strict warnings as errors
swift build -Xswiftc -warnings-as-errors

# Run CLI scanner in dry-run mode
swift run dev-sentry scan --dry-run
```

---

## 🛡️ 3. Critical Invariants

1. **Safety Invariants**:
   - Never implement recursive directory deletion without calling `ImmunityManager.isProtected(path:)`.
   - Never bypass the 24-hour active project immunity guard without explicit user override.
2. **Path Sanitization**:
   - Always expand tildes (`~`) safely using `FileManager.default.homeDirectoryForCurrentUser`.
   - Never accept arbitrary relative paths without canonicalizing them (`standardizingPath`).
3. **Swift 6 Strict Concurrency**:
   - All scan results and progress callbacks across actors must be `Sendable`.
