# ⚙️ gg3utils

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Languages](https://img.shields.io/badge/Made%20With-Python%20%7C%20Bash-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

**A lightweight toolkit of reusable Bash and Python utilities for system automation, monitoring, and networking.**

Part of the **GG3-DevNet infrastructure**, maintained by **Juan Garcia** (`@0xjuang`).

---

## 📚 Included Scripts

### `cc.sh` — GG3 Command Center
A Bash-powered **command center** built using `dialog`.
Features a custom ASCII art banner and a menu-driven interface for common file and folder operations.

- Folder synchronization
- File copy tasks
- Simple TUI (text-based) menu system
- Designed for lightweight local operations

### `sys_info.sh` — System Info Display
A minimal system information tool for quick reference to hardware, OS, and environment details.
Similar to NeoFetch but intentionally stripped of flashy visuals for pure clarity.

- CPU and memory info
- OS and kernel version
- Basic system specs

### `logging_utils.py` — Logging Utilities
A Python module for consistent logging across scripts and applications.
Supports output to:

- Terminal (with color-coded levels)
- Log files (default: `gg3utils.log`)
- Quiet mode (`//quiet` flag)

Built for modular reuse in both small scripts and larger automation workflows.

### `net3.py` — Network Utilities REPL
A REPL-style (interactive shell) toolkit for networking tasks and security operations.

- `networking` commands (basic checks)
- `services` commands (placeholder for service status tasks)
- `security` commands (future expansion)

Intended as a foundation for growing into a complete infrastructure toolkit.

---

## 🗂️ Folder Structure

```
gg3utils/
├── cc.sh
├── sys_info.sh
├── logging_utils.py
├── net3.py
├── .gitignore
└── README.md
```

---

## 🛤️ Project Roadmap

The following features are planned for future versions:

- Add network diagnostic tools (e.g., ping, traceroute) inside CC.sh
- Integrate a basic port scanner module
- Implement a service status checker in CC.sh
- Expand net3.py REPL functionality with additional networking, service, and security tools
- Create additional Bash utilities for system maintenance

---

## 🛡️ Notes

- `gg3utils.log` should be gitignored (only runtime logs).
- `__pycache__/` will also be ignored as standard Python cache output.
- This project follows simple, modular design principles for maximum reusability across projects.

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

> **Curated under the GG3-DevNet Infrastructure Stack — designed for reproducibility, auditability, and clarity.**
