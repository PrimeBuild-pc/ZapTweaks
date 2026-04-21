# ZapTweaks

[![Release](https://img.shields.io/github/v/release/PrimeBuild-pc/ZapTweaks?label=release)](https://github.com/PrimeBuild-pc/ZapTweaks/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/PrimeBuild-pc/ZapTweaks/total?color=success)](https://github.com/PrimeBuild-pc/ZapTweaks/releases/latest)
[![Codecov](https://codecov.io/gh/PrimeBuild-pc/ZapTweaks/branch/main/graph/badge.svg)](https://codecov.io/gh/PrimeBuild-pc/ZapTweaks)
[![License](https://img.shields.io/github/license/PrimeBuild-pc/ZapTweaks)](LICENSE)
[![Stars](https://img.shields.io/github/stars/PrimeBuild-pc/ZapTweaks?style=social)](https://github.com/PrimeBuild-pc/ZapTweaks/stargazers)
[![Issues](https://img.shields.io/github/issues/PrimeBuild-pc/ZapTweaks)](https://github.com/PrimeBuild-pc/ZapTweaks/issues)
[![Last Commit](https://img.shields.io/github/last-commit/PrimeBuild-pc/ZapTweaks)](https://github.com/PrimeBuild-pc/ZapTweaks/commits/main)

Windows 11 optimization workstation focused on gaming performance, system responsiveness, and practical maintenance workflows.

<img width="1400" height="956" alt="image" src="https://github.com/user-attachments/assets/c4c6ca99-89f4-41d7-bce8-40a8f1512e2e" />

Current version: v1.4.1

## Features
- Fluent UI desktop app built with Flutter for Windows.
- Toggle-based system tweaks with apply and revert support.
- Action tools for scripts, launchers, diagnostics, and installers.
- Category presets for fast baseline profiles.
- Hardware-aware availability filtering (CPU and GPU vendors).
- Built-in restart-required tracking and one-click restart flow.
- Optional dry-run mode for safe command validation.
- Expanded Power & CPU suite with advanced toggles, including boost mode, C-state/idle policies, processor min/max states, timer behavior, and BCD timer sync controls.
- Hardware-aware CPU-vendor-gated tweaks (Intel HWP and AMD preferred cores).

## Requirements
- Windows 11 (22H2 or newer).
- Administrator privileges.
- Supported hardware: Intel or AMD CPU, NVIDIA or AMD or Intel GPU.

## Installation
Download the latest installer from Releases:

https://github.com/PrimeBuild-pc/ZapTweaks/releases

Install latest release via PowerShell (run PowerShell as Administrator):

```powershell
irm https://raw.githubusercontent.com/PrimeBuild-pc/ZapTweaks/main/scripts/installer-latest.ps1 | iex
```

Alternative using iwr:

```powershell
iwr https://raw.githubusercontent.com/PrimeBuild-pc/ZapTweaks/main/scripts/installer-latest.ps1 -UseBasicParsing | iex
```

## Tweaks Categories
- Home: dashboard and quick access overview.
- Gaming: low-latency and game-focused optimizations.
- Networking: connection and adapter performance tuning.
- Power & CPU: processor policy and power behavior controls.
- Graphics: GPU-focused script and utility actions.
- Windows: core OS behavior and update policy tweaks.
- System Checks: health checks and diagnostics.
- Refresh & Recovery: recovery scripts and maintenance actions.
- Setup: installers and post-install setup automation.
- Advanced: expert-only tweaks with stronger impact.
- Privacy: telemetry and tracking reduction options.
- Visuals: shell and UI responsiveness cleanup.
- Tools: bundled external utilities and helper launchers.

## Safety
- Restore point creation gate for aggressive operations.
- Dry-run mode to preview command execution.
- Revert capability for all toggle-based tweaks.

## Building from Source
```bash
flutter pub get
flutter build windows --release
```

## License
This project is licensed under the MIT License. See LICENSE for details.
