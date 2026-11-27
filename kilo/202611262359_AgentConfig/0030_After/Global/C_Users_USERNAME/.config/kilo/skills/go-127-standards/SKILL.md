---
name: go-127-standards
description: Use ONLY when writing, refactoring, debugging, or reviewing Go (.go) source files or go.mod files. Do not load for shell scripts, SQL, configuration files, or non-Go languages.
---

# Go v1.27 Development Standards

## Core Directives
- **Strict Compliance**: All generated Go code must strictly adhere to Go 1.27 features, idioms, and standard library conventions. Reject and avoid any deprecated functions or obsolete patterns documented in the local knowledge base.
- **Minor Version Tolerance**: A project's `go.mod` patch version (e.g., `1.27.3`) may differ from the documentation version (`1.27.0`). Ignore this discrepancy and treat the local `1.27.0` documentation as authoritative.
- **Verify Before Coding**: Do not guess version-specific syntax or behavior. Query the targeted reference path below before outputting code.

## Targeted Knowledge Lookup (Context-Safe)
- **Incremental 1.27 features & version differences**: Use `search_files` inside `F:/Go_Knowledge/releases/`
- **Core language mechanics & grammar**: Use `search_files` (with a specific regex keyword) on `F:/Go_Knowledge/language-spec.md/language-spec.md`. **CRITICAL: Never read the entire `language-spec.md` file at once.**