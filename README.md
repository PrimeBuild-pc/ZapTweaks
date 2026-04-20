# ZapTweaks

Windows 11 optimization workstation focused on gaming performance, system responsiveness, and practical maintenance workflows.

Current version: v1.4.0

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
