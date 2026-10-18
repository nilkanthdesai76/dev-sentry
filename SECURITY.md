# SECURITY.md — DevSentry Safety & File Protection Standards

> Fail-safe directory boundaries, immunity guardrails, and non-destructive deletion policies for DevSentry.

---

## 🔒 1. System Path Boundaries

DevSentry enforces hardcoded blacklist protection. Under no circumstances will DevSentry attempt to delete or alter files within:
- `/System`, `/usr`, `/bin`, `/sbin`, `/var`, `/private`
- `/Applications`, `/Library` (outside explicit designated developer cache subfolders)
- User home directory root (`~`), Desktop, Documents, Downloads

---

## 🛡️ 2. Active Project Immunity Lock

- Any project directory containing active Git commits or file modifications made in the preceding 24 hours receives automatic immunity.
- Mass-purge commands (`--all`, `--force`) explicitly skip immune projects unless the user explicitly passes `--include-active-projects`.
