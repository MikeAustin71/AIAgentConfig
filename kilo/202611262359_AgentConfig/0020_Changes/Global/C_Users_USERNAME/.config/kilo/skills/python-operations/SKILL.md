---
name: python-operations
description: Use this skill ONLY when using python files, creating or executing python programs. 
---

## python-operations

> **MANDATORY**: All python operations must be structured in strict accordance with the rules defined in this document. Never bypass these rules.

---

- The source code in this Project Directory is primarily written in ***go***, with a dedicated Python workspace in directory `py_tools/`.
- Python programs are often used to verify and validate mathematical calculation results.
- All Python operations must be conducted in, and all files created in, the `py_tools/` directory tree.
- Place all Python scripts and dependencies (`requirements.txt`) inside `py_tools/`.
- You are authorized to create subdirectories under the `py_tools/` directory in support of your task assignments.
- Python 3.14 is configured in a virtual environment at `py_tools\.venv\`.
- **Always** execute Python and pip using the virtual environment's executable directly from the project root (do not call global `python`, `python3`, or `pip`):
  - Run Python: `.\py_tools\.venv\Scripts\python.exe <script.py>`
  - Run pip: `.\py_tools\.venv\Scripts\python.exe -m pip <command>`
- Never read, search, or modify files inside `py_tools\.venv\`.

