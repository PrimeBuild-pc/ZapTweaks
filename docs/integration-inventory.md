# ZapTweaks integration inventory

This is the baseline recorded before the multilingual, power-plan, and external-tool expansion.

## Current catalog

- Total descriptors: **239**
- IDs are expected to be unique and stable.
- Categories:

| Category | Count |
|---|---:|
| Gaming | 16 |
| Networking | 11 |
| Power & CPU | 16 |
| Graphics | 13 |
| Windows | 39 |
| System Checks | 15 |
| Refresh & Recovery | 7 |
| Setup | 12 |
| Advanced | 20 |
| Privacy | 10 |
| Visuals | 12 |
| Tools | 68 |

## Supplied power-saving inputs

| Input | Existing overlap | Planned integration |
|---|---|---|
| `DISABLE-POWERSAVING.txt` | `NetworkAdapterPowerSavingsTweak` covers part of the NIC registry policy. | Merge useful physical-NIC settings into that toggle with state backup and exact revert. |
| `NetAdapter.bat` | Mostly duplicates the existing network-adapter toggle and interactive script. | Do not bundle; merge only missing behavior. |
| `Device Power-Saving.bat` | Similar interactive resource exists, but no native stateful toggle. | Add one native aggressive device-power toggle with state backup and exact revert. |
| `tweak utili W11.txt` | Game Mode, HAGS, windowed optimizations, HVCI, timers, CPU and NIC power have partial implementations. | Correct contradictory settings and avoid duplicate catalog entries. |

The supplied `.txt` and `.bat` files are inputs only and must not be copied into `resources`.

## Power plans

- Bundled before expansion: **22**
- Supplied `.pow` files: **90**
- Same filename in both sets: **21**
- Same filename and SHA-256: **17**
- Same filename but different SHA-256: **4**
- New filenames: **69**
- Bundled-only plan: `Exm Free Power Plan V2.pow`
- Expected merged total when existing filenames are retained: **91**

Same-name files requiring a deliberate version choice:

| Filename | Bundled SHA-256 | Supplied SHA-256 |
|---|---|---|
| `ancel.pow` | `6cf954dd4c5f2a7c800e06ae4d13b4766a601534ad5ec990cf5f61afcd966834` | `cad7da998b44d0f9236bab77142da253794466c493f8c2a6d329a36d484c3698` |
| `calypto.pow` | `50d869f328fd29cc3a079d401d895ee3ab68db5fc4fb3e71af8b30ebc03dc0bf` | `689a149f62670c7926e82ce004d8870761af084b335921d9e048d22428d70eac` |
| `kaisen.pow` | `5c2003f0f5a0aea329f70f82803455fb254cdfa1464e59336830c179a75a4a3f` | `dfdf96288eaeb82d92adae4e22598ae186f59ad0dd421f8a40607895b0e8ac0f` |
| `kizzimo.pow` | `b4fd46b063397cb4c36a030aeaba3a6583e46d4886222425b8ef82a403377512` | `1f470ca6497602a332a9349bcdee3ecda774038335e8c719f1c797ede35bc72d` |

`FixPowerPlans.reg` is excluded because it changes `PlatformAoAcOverride` and is not a power-plan file.

## External integrations

| Integration | Current state | Distribution decision |
|---|---|---|
| Beyond Performance Device Tweaker | Absent; canonical script URL still required. | Do not use the unrelated/disputed C# port. Pin the canonical script before adding an action. |
| `imribiy/amd-gpu-tweaks` | Some AMD registry behavior overlaps existing tweaks; upstream has no declared license. | No script vendoring without permission; independently verify each allowed registry value. |
| SCEWIN-GUI | Absent; upstream GUI is MIT licensed. | Bundle a pinned release with license and checksum after binary verification. |
| NVIDIA NVFlash | Absent. | Open a trusted download page; do not bundle or automate flashing. |
| AMDVBFlash/ATIFlash | Absent. | Open a trusted download page; do not bundle or automate flashing. |

## Safety baseline

- Aggressive actions require the existing safety gate and clear warnings.
- Hardware-specific actions must be hidden or disabled on incompatible hardware.
- Existing values must be recorded before changing NIC, device, or AMD registry state.
- Remote scripts must use a canonical immutable source; mutable `irm ... | iex` endpoints are not acceptable for the new integrations.
- GPU/VBIOS and firmware tools remain launchers only; ZapTweaks must not choose images or issue flash commands.
