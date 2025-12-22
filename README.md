# ⚡ ZapTweaks

[![Platform](https://img.shields.io/badge/platform-Windows%2011-blue.svg)](https://www.microsoft.com/windows)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/PrimeBuild-pc/ZapTweaks.svg)](https://github.com/PrimeBuild-pc/ZapTweaks/releases)

> **Simple & Fast Windows 11 Gaming System Optimizer by PrimeBuild**

ZapTweaks is a simple desktop application designed to optimize Windows 11 systems for better gaming performance through basic system tweaks and optimizations.

<img width="641" height="966" alt="image" src="https://github.com/user-attachments/assets/1c492a00-9364-48eb-a8ab-a7803ef9bfe1" />

## ✨ Features

### 🚀 Performance Optimization
- **CPU Tweaks** - Core parking, C-States, power throttling
- **GPU Optimization** - HAGS, MPO, dedicated settings for NVIDIA/AMD/Intel
- **RAM Management** - Paging optimization, SysMain control
- **Storage** - SSD TRIM, AHCI, NVMe optimizations

### ⚙️ System Configuration
- **Boot & System** - Fast boot, hibernation control, dynamic tick optimization
- **Network** - Nagle's algorithm, RSS, NetBIOS, network throttling
- **Timer Resolution** - HPET configuration, system timer optimization
- **Visual Effects** - UI animations, transparency, visual performance

### 🎮 Gaming Enhancements
- **Game Mode** - Windows Game Mode control
- **Game DVR** - Xbox Game Bar management
- **Fullscreen Optimizations** - FSO control
- **Priority Tweaks** - Process scheduling optimization

### 🔒 Privacy & Telemetry
- **Telemetry Blocking** - DiagTrack, Connected User Experiences
- **Privacy Controls** - Activity tracking, advertising ID, feedback
- **Services Management** - Disable unnecessary Windows services

### 🔧 Advanced Tools
- **Power Plans** - Import custom performance power plans (Atlas, Bitsum, and more)
- **Full Debloat Script** - Comprehensive Windows cleanup
- **Chris Titus Tech Utility** - Quick access to CTT Windows Utility

### 💡 Smart Features
- **Restart Detection** - Automatically tracks which changes require restart
- **One-Click Revert** - Toggle any tweak on/off instantly
- **Persistent Settings** - Your preferences are saved between sessions
- **Admin Elevation** - Automatically requests necessary privileges

## 📥 Installation

### Requirements
- Windows 11 (64-bit)
- Administrator privileges
- ~15MB disk space

### Download & Install

1. Download the latest release from [Releases](https://github.com/PrimeBuild-pc/ZapTweaks/releases)
2. Extract `ZapTweaks_v1.0_Windows.zip` to your desired location
3. Run `script_utility.exe` as Administrator
4. Apply your desired tweaks
5. Restart when prompted

## 🎯 Quick Start

1. **Launch** ZapTweaks as Administrator
2. **Browse** through optimization categories
3. **Toggle** switches to enable/disable tweaks
4. **Watch** the restart indicator (🔄) turn orange when restart is needed
5. **Apply** and restart your system

## 🛠️ Building from Source

### Prerequisites
```bash
flutter --version  # Flutter 3.10+
```

### Build Instructions
```bash
# Clone the repository
git clone https://github.com/yourusername/ZapTweaks.git
cd ZapTweaks

# Get dependencies
flutter pub get

# Build for Windows
flutter build windows --release

# Output: build/windows/x64/runner/Release/script_utility.exe
```

## 📋 What Gets Tweaked?

<details>
<summary><b>CPU & Performance</b></summary>

- Core Parking Control
- CPU C-States Management
- Power Throttling Disable
- CPU Idle State Control
- Core Unparking

</details>

<details>
<summary><b>GPU Optimization</b></summary>

- Hardware Accelerated GPU Scheduling (HAGS)
- Multi-Plane Overlay (MPO)
- GPU Power Management
- Vendor-Specific Tweaks (NVIDIA/AMD/Intel)

</details>

<details>
<summary><b>Network</b></summary>

- Nagle's Algorithm Disable
- Network Throttling Index
- RSS Settings
- NetBIOS Control
- Network Power Management

</details>

<details>
<summary><b>Services Disabled</b></summary>

- Diagnostic Tracking Service
- Windows Search
- SysMain (Superfetch)
- Windows Update (optional)
- Remote Registry
- And many more...

</details>

## ⚠️ Important Notes

- **Always create a system restore point** before applying tweaks
- **Requires Administrator privileges** to modify system settings
- **Restart required** for most tweaks to take effect
- Some tweaks may affect system stability - use at your own discretion
- **Not recommended for production workstations** - optimized for gaming

## 🔄 Reverting Changes

All tweaks can be instantly reverted by toggling the switches back to their OFF position. The app maintains the exact registry/system state for proper restoration.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Chris Titus Tech for Windows optimization utilities
- Community power plan creators (Atlas, Bitsum, Kaisen, etc.)
- Flutter framework and Windows desktop support
- All contributors and testers

💖 Support the project

Do you like this tool? Buy me a coffee ☕:

[![PayPal](https://img.shields.io/badge/Supporta%20su-PayPal-blue?logo=paypal)](https://paypal.me/PrimeBuildOfficial?country.x=IT&locale.x=it_IT)

**Made with ❤️ and ☕ by PrimeBuild⚡**

---

**Disclaimer**: This tool modifies Windows system settings. While all changes are reversible, always backup your system before applying optimizations. Use at your own risk.
