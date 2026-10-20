# TESTING.md — DevSentry Test Strategy

> Test architecture, mock directory sandboxes, and safety immunity tests for DevSentry.

---

## 🧪 1. Test Strategy

1. **Immunity Logic Tests**:
   - Creates temporary test folders with mock `stat` modification dates (1 hour ago, 23 hours ago, 25 hours ago, 45 days ago) and verifies that items under 24 hours are marked `isImmune = true`.
2. **Byte Formatter Unit Tests**:
   - Tests boundary conditions: $0\text{ bytes}$, $1023\text{ bytes}$, $1024\text{ bytes}$ ($1\text{ KB}$), $1\text{ MB}$, $1\text{ GB}$, $1\text{ TB}$.
3. **Sandbox Deletion Tests**:
   - Exercises `APFSDirectoryCleaner` strictly inside `NSTemporaryDirectory()` sandboxes to verify clean, non-blocking asynchronous directory removal.
4. **Path Guardrail Rejection Tests**:
   - Asserts that attempting to clean protected system paths (`/`, `/System`, `/Users`, `/Applications`) throws immediate `SecurityViolationError` exceptions.

---

## ⚡ 2. Execution Commands

```bash
# Run all unit tests
swift test

# Run immunity tests specifically
swift test --filter ImmunityManagerTests
```
