<div align="center">
  <h1>⚡ ZapTweaks</h1>
  <p><strong>Advanced Windows 11 optimization and diagnostics companion.</strong></p>
  <p>
    <a href="https://github.com/PrimeBuild-pc/ZapTweaks/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/PrimeBuild-pc/ZapTweaks?label=release"></a>
    <a href="https://github.com/PrimeBuild-pc/ZapTweaks/releases/latest"><img alt="Latest release downloads" src="https://img.shields.io/github/downloads/PrimeBuild-pc/ZapTweaks/latest/total?label=downloads%40latest&color=success"></a>
    <a href="https://github.com/PrimeBuild-pc/ZapTweaks/actions/workflows/flutter-ci.yml"><img alt="Flutter CI" src="https://github.com/PrimeBuild-pc/ZapTweaks/actions/workflows/flutter-ci.yml/badge.svg"></a>
    <a href="https://codecov.io/gh/PrimeBuild-pc/ZapTweaks"><img alt="Codecov" src="https://img.shields.io/codecov/c/github/PrimeBuild-pc/ZapTweaks?label=coverage"></a>
    <a href="LICENSE"><img alt="MIT License" src="https://img.shields.io/github/license/PrimeBuild-pc/ZapTweaks"></a>
  </p>
</div>

It is not intended to replace common baseline tools such as [CTT WinUtil](https://github.com/ChrisTitusTech/winutil) or [Winhance](https://github.com/memstechtips/Winhance). Use those for broad setup and debloating, then use ZapTweaks for deeper gaming, latency, hardware, networking, graphics, power, diagnostics, and recovery workflows. Both companion tools can be launched or installed from ZapTweaks itself.

<img width="1400" height="956" alt="ZapTweaks" src="https://github.com/user-attachments/assets/c4c6ca99-89f4-41d7-bce8-40a8f1512e2e" />

## Highlights

- Fluent UI desktop app built for Windows 11.
- Advanced gaming, CPU, GPU, networking, timer, power, privacy, and shell controls.
- Hardware-aware availability for Intel, AMD, and NVIDIA systems.
- Apply/revert support and state verification for toggle-based tweaks.
- Restore-point gate for aggressive operations.
- Dry-run mode for command validation without system changes.
- Live CPU, GPU, RAM, and VRAM dashboard.
- Bundled diagnostics, installers, scripts, power plans, and recovery tools.
- Built-in update checks and installer flow.
- Direct access to CTT WinUtil and Winhance for complementary baseline work.

## Categories

- **Home:** live metrics and detected hardware.
- **Gaming:** latency and game-focused optimizations.
- **Networking:** TCP, adapter, offload, and power controls.
- **Power & CPU:** processor policies, boost behavior, timers, and power plans.
- **Graphics:** driver, display, flip-model, and GPU utility workflows.
- **Windows:** operating-system behavior and maintenance.
- **System Checks:** health checks and diagnostics.
- **Refresh & Recovery:** repair and recovery actions.
- **Setup:** post-install configuration tools.
- **Advanced:** expert-only and higher-impact operations.
- **Privacy:** telemetry and background-content controls.
- **Visuals:** shell and UI behavior.
- **Tools:** bundled utilities plus CTT WinUtil and Winhance.

## Requirements

- Windows 11 22H2 or newer.
- Administrator privileges.
- x64 system.

## Installation

Download the installer or portable package from [GitHub Releases](https://github.com/PrimeBuild-pc/ZapTweaks/releases/latest).

Install the latest release from an elevated PowerShell window:

```powershell
irm https://raw.githubusercontent.com/PrimeBuild-pc/ZapTweaks/main/scripts/installer-latest.ps1 | iex
```

## Safety

ZapTweaks exposes advanced settings that can affect stability, security, power use, and network behavior. Read each description, create restore points when requested, and avoid applying changes you do not understand. Remote-script actions display a warning before execution.

## Build from source

```powershell
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

The Windows CMake build copies the complete `resources` directory next to the executable. Create the portable package with:

```powershell
./build_portable.ps1 -SkipFlutterBuild
```

## License

Licensed under the [MIT License](LICENSE). Third-party tools retain their respective licenses.
