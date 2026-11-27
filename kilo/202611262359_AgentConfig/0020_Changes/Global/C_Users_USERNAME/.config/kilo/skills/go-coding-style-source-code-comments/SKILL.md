---
name: go-coding-style-source-code-comments
description: Use this skill ONLY when creating or configuring configuring source code comments in the 'Go' programming language. 
---

# go-coding-style-source-code-comments

## Agent Directive

> **MANDATORY**: Source Code Comments are required for all new Functions, Methods, Custom Types, and Interfaces. Explain *What* it is, *Why* it exists, and *Contracts/Assumptions*. Do not explain code line-by-line. <u>Use tabs when indenting source code comments.</u> Never bypass these rules.

---

## Source Code Comments

### **A. Type & Interface Comments**

Must begin with the Type/Interface name, form a complete sentence, and describe the purpose/behavior.

```go
//	NaturalLogCalculator computes natural logarithms using AGM, Newton,
//	or Taylor numerical methods.
type NaturalLogCalculator struct { ... }
```

### **B. Function & Method Comments**

Must follow this exact structure, including explicit "Input Parameters" and "Return Parameters" sections:

```go
//	NaturalLog returns ln(x). The function requires x > 0.
//
//	Input Parameters
//	----------------
//
//	x float64
//	'x' is the input value for which the Natural Log will be calculated.
//
//	Return Parameters
//	-----------------
//
//	float64 
//	Returns the Natural Log value for input parameter 'x'.
func NaturalLog(x float64) float64 { ... }
```

### C. Package Comments

Every package should have a package comment placed immediately above the `package` clause. [[1](https://go.dev/doc/comment)]

- **Single-file packages.** Put the comment directly above `package <name>` in your main file.
- **Multi-file packages.** Place the package comment in a dedicated file named `doc.go` (containing only the comment and the `package <name>` line) so it is easy to locate.
- **Naming rule.** Always begin the first sentence with `Package <name>`. [[1](https://go.dev/doc/comment)]

```go
// Package errpref provides structured error formatting and contextual
// wrapping utilities for multi-layer applications.
package errpref
```

