# DevSentry 🧹⚡

> High-speed, safety-guaranteed developer storage vacuum for macOS. Reclaims 30GB–80GB of Xcode DerivedData, inactive `node_modules`, and old Simulators in seconds.

[![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B-blue.svg)](https://developer.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![APFS](https://img.shields.io/badge/Filesystem-APFS%20Optimized-green.svg)](https://apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

- ⚡ **2-Second APFS Deep Index** — Recursively scans developer caches across your entire SSD in under 2.5 seconds using optimized Apple File System traversal.
- 🛡️ **24-Hour Active Project Immunity** — Automatically locks projects modified within the last 24 hours to prevent disrupting active coding sessions.
- 🍏 **Xcode & Apple Tooling Vacuum** — Cleans stale `DerivedData`, archives older than 90 days, legacy device support files, and dead simulator runtimes (`simctl`).
- 📦 **Inactive `node_modules` & SPM Hunter** — Pinpoints abandoned dependency folders in stale projects untouched for months.
- 🐳 **Docker Reclaimer** — Reports and purges dangling build caches and dead container volumes without command-line wrangling.
- 🖥️ **Dual Interface** — Interactive, beautiful SwiftUI macOS app + fast, scriptable Terminal CLI.

---

## ⚡ Quick Start

```bash
# Clone and build
git clone https://github.com/nilkanthdesai76/dev-sentry.git
cd dev-sentry

# Run tests
swift test

# Run dry-run scan via CLI
swift run dev-sentry scan --dry-run
```

---

## 📚 Documentation Pillars
- [PRD.md](docs/PRD.md) — Product specifications and acceptance criteria
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Storage scanning engines and APFS taxonomy
- [AGENTS.md](AGENTS.md) — Operational instructions for AI coding assistants
- [TESTING.md](docs/TESTING.md) — Test strategies and mock directory sandboxes
- [SECURITY.md](docs/SECURITY.md) — Fail-safe system boundaries and immunity rules
