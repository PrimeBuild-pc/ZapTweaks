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

## Bundled scripts

| Script | Frozen source | License |
|---|---|---|
| Repair Bad Tweaks by zoicware | https://github.com/zoicware/RepairBadTweaks/tree/0afa349ba7dca7a44eb8a5e64de1a38ae12f71a5 | MIT; upstream `RepairTweaks.ps1` SHA-256 `a5bc79aa76a72f56a433ed09633867163fcbe9249fc41ef8e6c30de5bac7060d`. |

Never use patched VBIOS tools that bypass vendor or board-ID protection. ZapTweaks does not select ROM images or issue flash commands.
