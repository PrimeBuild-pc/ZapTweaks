# Third-party notices

ZapTweaks does not bundle the following tools in this release. Their launcher entries open the stated canonical download/release pages so the user can review current release notes, hashes, and licenses before downloading.

| Tool | Source | License / distribution |
|---|---|---|
| SCEWIN-GUI | https://github.com/eskezje/SCEWIN-GUI | MIT upstream; not bundled because SCEWIN/AMISCE firmware tooling and hardware compatibility remain user-specific. |
| NVIDIA NVFlash | https://www.techpowerup.com/download/nvidia-nvflash/ | Proprietary utility; not redistributed. |
| AMDVBFlash | https://www.techpowerup.com/download/amdvbflash/ | Proprietary utility; not redistributed. |
| `imribiy/amd-gpu-tweaks` | https://github.com/imribiy/amd-gpu-tweaks | No upstream license was identified; its batch file is not copied or distributed by ZapTweaks. The native AMD Safe Profile is a limited clean-room implementation and excludes thermal, power-gating, Crash Defender, and MPO changes. |
| Beyond Performance Device Tweaker | https://discord.gg/eGmDd28m4k | Public author-provided Discord distribution; ZapTweaks opens the channel but does not bundle a mutable Discord attachment. |

## App catalog sources

| Catalog | Frozen source | Treatment |
|---|---|---|
| CTT WinUtil | https://github.com/ChrisTitusTech/winutil/tree/a0d3c719a6611b329422e9c56ee9b792cd596146 | MIT; package identities are normalized with attribution. |
| TweakHub | https://github.com/PrimeBuild-pc/TweakHub/tree/bdc6e185ddc062bf906d2d9950b62d252f381110 | MIT; package identities are normalized with attribution. |
| Windows 11 Fix Tweaks by kubaam | https://github.com/kubaam/Windows-11-Fix-Tweaks/tree/8da4fe0251f3c46aec6434e38e7a92f06307313a | MIT; the source launcher is retained, but the all-in-one batch is not bundled or executed. Reviewed file SHA-256 `12d257371e49f18f0a0d7b98ee1e48d5bdd116ce136af322f9cbfa24aed9e37e`. |
| Winhance | https://github.com/memstechtips/Winhance/tree/f23d554eb2d6400b1827bcc46b91294ffa53fbc9 | PolyForm Shield 1.0.0; no source code, descriptions, or implementation copied. Only factual package candidates were independently normalized. |

## Linked maintenance, tuning, and validation tools

These entries are links only. ZapTweaks neither bundles nor silently executes them.

| Tool family | Canonical sources | License / treatment |
|---|---|---|
| Repair Bad Tweaks by zoicware | https://github.com/zoicware/RepairBadTweaks/tree/0afa349ba7dca7a44eb8a5e64de1a38ae12f71a5 | MIT; reviewed `RepairTweaks.ps1` SHA-256 `a5bc79aa76a72f56a433ed09633867163fcbe9249fc41ef8e6c30de5bac7060d`; not bundled. |
| zoicware MIT projects | https://github.com/zoicware/ZOICWARE, https://github.com/zoicware/DefenderProTools, https://github.com/zoicware/RemoveWindowsAI, https://github.com/zoicware/RemoveCBSApps, https://github.com/zoicware/PowerPlanSettingsEditor, https://github.com/zoicware/ServiceManagerPlus, https://github.com/zoicware/WindowsDeviceRemover, https://github.com/zoicware/RemoveAppsPolicyEditor, https://github.com/zoicware/TweakFTH | MIT upstream; linked with attribution, not copied. |
| zoicware source-only projects | https://github.com/zoicware/zScripts, https://github.com/zoicware/PBOTuner2, https://github.com/zoicware/UltimateDiskCleanup, https://github.com/zoicware/WindowsUpdateManager, https://github.com/zoicware/DynamicMinServices, https://github.com/zoicware/zTurbo, https://github.com/zoicware/OverrideEDID, https://github.com/zoicware/HostsBuilder | No explicit license identified in the reviewed GitHub repository metadata; links only, no code copied. |
| BenchMate | https://benchmate.org/ | Publisher download; not redistributed. |
| Linpack Xtreme | https://www.techpowerup.com/download/linpack-xtreme/ | Publisher download hosted by TechPowerUp; not redistributed. |
| OCCT | https://www.ocbase.com/download | Publisher download; not redistributed. |
| y-cruncher | https://www.numberworld.org/y-cruncher/ | Author download; not redistributed. |
| Cinebench 2024 | https://www.maxon.net/en/downloads/cinebench-2024-downloads | Maxon download; not redistributed. |
| MemTest86 | https://www.memtest86.com/download.htm | PassMark download; not redistributed. |
| CoreCycler | https://github.com/sp00n/corecycler | Upstream project license applies; linked, not copied. |
| MSI Mode Utility | https://github.com/vadyaravadim/msi-mode-utility/tree/20a8402adb4d8f31949aed9affba41b961a73cf2 | MIT; reviewed as a reference for per-device `Enum\\PCI` MSI state and exact absent-value rollback. No PowerShell code is bundled or executed. |
| GoInterruptPolicy | https://github.com/spddl/GoInterruptPolicy/tree/f41fd1e325e1d3a386816c3586474e5f7bb63a25 | MIT; reviewed as a reference for SetupAPI capability discovery, per-device interrupt policy state and variable-width affinity masks. No Go code is bundled or executed. |
| WINSPAR Windows TCP Optimizer by powplowdevs | https://github.com/powplowdevs/WINSPAR-Windows-TCP-Optimizer/tree/6392524fcd51925ffe0e082a76facf5b3bb8f322 | AGPL-3.0; reviewed only as a behavioral reference for TCP state, manual controls, application QoS, diagnostics and backup/restore. ZapTweaks' native MIT implementation is clean-room and uses documented Windows `NetTCPIP`/`NetQos` interfaces: no upstream C++/Java/Python code, binaries, test payloads or artwork is copied, bundled, downloaded or executed. |

The ISO-modification, archived edition-conversion, theme, Discord-icon, and developer-only zoicware repositories are intentionally not exposed because they are outside ZapTweaks' supported scope.

Never use patched VBIOS tools that bypass vendor or board-ID protection. ZapTweaks does not select ROM images or issue flash commands.
