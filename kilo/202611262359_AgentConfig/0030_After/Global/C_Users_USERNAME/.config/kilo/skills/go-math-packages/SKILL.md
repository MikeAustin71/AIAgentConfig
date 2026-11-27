---
name: go-math-packages
description: Use ONLY when writing, refactoring, or debugging Go code that imports or uses the standard library `math` or `math/big` packages. Do not load for general Go tasks or other languages.
---

# Go v1.27 Math & Math/Big Reference

## Rules
- Verify function signatures, rounding modes, precision rules, and Go 1.27 behavior against the local package documentation before writing code.
- Ignore patch version differences between `go.mod` (e.g., `1.27.3`) and the `1.27.0` reference files.

## Package Documentation Paths
- **`math/big` package**: Read or search `F:/Go_Knowledge/packages/math_big_go1.27.0.md`
- **`math` package**: Read or search `F:/Go_Knowledge/packages/math_go1.27.0.md`