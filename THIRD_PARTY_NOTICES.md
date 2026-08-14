# Third-party notices

ZapTweaks does not bundle the following tools in this release. Their launcher entries open the stated canonical download/release pages so the user can review current release notes, hashes, and licenses before downloading.

| Tool | Source | License / distribution |
|---|---|---|
| SCEWIN-GUI | https://github.com/eskezje/SCEWIN-GUI | MIT upstream; not bundled because SCEWIN/AMISCE firmware tooling and hardware compatibility remain user-specific. |
| NVIDIA NVFlash | https://www.techpowerup.com/download/nvidia-nvflash/ | Proprietary utility; not redistributed. |
| AMDVBFlash | https://www.techpowerup.com/download/amdvbflash/ | Proprietary utility; not redistributed. |
| `imribiy/amd-gpu-tweaks` | https://github.com/imribiy/amd-gpu-tweaks | No upstream license was identified; its batch file is not copied or distributed by ZapTweaks. The native AMD Safe Profile is a limited clean-room implementation and excludes thermal, power-gating, Crash Defender, and MPO changes. |
| Beyond Performance Device Tweaker | https://discord.gg/eGmDd28m4k | Public author-provided Discord distribution; ZapTweaks opens the channel but does not bundle a mutable Discord attachment. |

Never use patched VBIOS tools that bypass vendor or board-ID protection. ZapTweaks does not select ROM images or issue flash commands.
