# ⚡ ZapTweaks

[![Platform](https://img.shields.io/badge/platform-Windows%2011-blue.svg)](https://www.microsoft.com/windows)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/PrimeBuild-pc/ZapTweaks.svg)](https://github.com/PrimeBuild-pc/ZapTweaks/releases)

> **Simple & Fast Windows 11 Gaming System Optimizer by PrimeBuild**

ZapTweaks is a simple desktop application designed to optimize Windows 11 systems for better gaming performance through basic system tweaks and optimizations.

<img width="641" height="966" alt="image" src="https://github.com/user-attachments/assets/1c492a00-9364-48eb-a8ab-a7803ef9bfe1" />

## ✨ Features

<details>
<summary><strong>🚀 Performance Optimization</strong></summary>

TweakHub provides advanced system-level optimizations focused on improving overall performance and responsiveness:

- **CPU Tweaks**  
  Optimize CPU behavior by adjusting core parking, C-States, and power throttling to reduce latency and improve consistency under load.

- **GPU Optimization**  
  Configure graphics-related settings such as Hardware Accelerated GPU Scheduling (HAGS), Multiplane Overlay (MPO), and apply vendor-specific optimizations for NVIDIA, AMD, and Intel GPUs.

- **RAM Management**  
  Improve memory usage by optimizing paging behavior and controlling services like SysMain to reduce unnecessary background activity.

- **Storage Optimization**  
  Apply SSD-specific tweaks including TRIM support, AHCI tuning, and NVMe performance optimizations for faster disk operations.

</details>

---

<details>
<summary><strong>⚙️ System Configuration</strong></summary>

Fine-tune core Windows system components to balance performance, stability, and efficiency:

- **Boot & System**  
  Control fast startup, hibernation behavior, and dynamic tick settings to reduce boot time and improve system responsiveness.

- **Network Optimization**  
  Improve network performance by adjusting Nagle’s algorithm, Receive Side Scaling (RSS), NetBIOS behavior, and removing network throttling limits.

- **Timer Resolution**  
  Configure HPET and system timers to achieve more precise timing, beneficial for real-time applications and gaming.

- **Visual Effects**  
  Reduce UI overhead by disabling unnecessary animations, transparency effects, and visual flourishes to prioritize performance.

</details>

---

<details>
<summary><strong>🎮 Gaming Enhancements</strong></summary>

Enhancements specifically designed to improve gaming performance and consistency:

- **Game Mode Control**  
  Enable or disable Windows Game Mode to ensure system resources are prioritized correctly during gameplay.

- **Game DVR Management**  
  Fully control Xbox Game Bar and Game DVR features to eliminate background recording overhead.

- **Fullscreen Optimizations (FSO)**  
  Enable or disable Fullscreen Optimizations to reduce input latency and avoid compatibility issues in certain games.

- **Priority Tweaks**  
  Optimize process scheduling and priorities to give games preference over background processes.

</details>

---

<details>
<summary><strong>🔒 Privacy & Telemetry</strong></summary>

Take back control over your data and reduce unnecessary background communication:

- **Telemetry Blocking**  
  Disable telemetry services such as DiagTrack and Connected User Experiences to minimize data collection.

- **Privacy Controls**  
  Manage activity tracking, advertising ID, feedback frequency, and other privacy-related Windows features.

- **Services Management**  
  Identify and disable unnecessary Windows services that impact performance or privacy.

</details>

---

<details>
<summary><strong>🔧 Advanced Tools</strong></summary>

Powerful tools for advanced users who want deeper control over their system:

- **Power Plans**  
  Import and manage custom high-performance power plans, including Atlas, Bitsum, and other community or custom profiles.

- **Full Debloat Script**  
  Execute a comprehensive debloating process to remove unnecessary Windows components, apps, and background tasks.

- **Chris Titus Tech Utility**  
  Direct access to the popular CTT Windows Utility for additional system tuning and configuration.

</details>

---

<details>
<summary><strong>💡 Smart Features</strong></summary>

Quality-of-life features designed to make system tweaking safe and user-friendly:

- **Restart Detection**  
  Automatically detects which tweaks require a system restart and notifies the user accordingly.

- **One-Click Revert**  
  Instantly enable or disable any tweak, allowing safe experimentation without permanent changes.

- **Persistent Settings**  
  All user preferences and applied tweaks are saved and restored between sessions.

- **Admin Elevation**  
  Automatically requests administrator privileges when required to apply system-level changes.

</details>

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

## 💖 Support the project

Do you like this tool? Buy me a coffee ☕:

[![PayPal](https://img.shields.io/badge/Supporta%20su-PayPal-blue?logo=paypal)](https://paypal.me/PrimeBuildOfficial?country.x=IT&locale.x=it_IT)

**Made with ❤️ by PrimeBuild⚡**

---

**Disclaimer**: This tool modifies Windows system settings. While all changes are reversible, always backup your system before applying optimizations. Use at your own risk.
