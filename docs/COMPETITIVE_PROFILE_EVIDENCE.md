# Competitive profile evidence gate

## Status (27 Oct 2026)

The **Competitive** preset exists, approved by the owner on 22 Oct 2026, as a *set of changes he chose*, not as a measured improvement. ZapTweaks makes **no FPS, latency or other performance claim** for it:

- the UI shows no gain number, an "Attention" risk badge, the full list of what it removes and an explicit consent checkbox;
- every automated item is a typed native operation with preview, snapshot and read-back (rules 1, 2, 4, 5, 6 below still apply);
- rule 3 (benefit evidence) is **not** met and is not claimed: items keep `benefitEvidence` `unverified`/`inferred`;
- rule 7 holds: no security protection is touched (Defender, firewall, HVCI/VBS, UAC, SmartScreen and Windows Update stay as they are);
- third-party steps (Fr33thy's clean driver install and WinSux) are shown with author and links but **not run**: their scripts download and execute files that cannot be pinned to a hash.

The definition lives in `lib/features/presets/domain/preset_catalog.dart`. The benchmark protocol below remains the future work needed before anything is ever described as faster.

## Original gate

No competitive profile was to be published or recommended until the package below existed. That still applies to any *recommended* or *performance-claiming* profile.

## Candidate operation policy

An operation may enter a candidate profile only when all of these are true:

1. It is present in the typed native operation catalog; legacy scripts, shell commands and external tools are excluded.
2. `mechanismEvidence` and `valueEvidence` are `documented` or `runtimeObserved`.
3. `benefitEvidence` is not `unverified`.
4. Live capability checks pass on the target machine.
5. The preview identifies the operation ID, target, desired value, restart impact and rollback capability.
6. Apply, read-back verification and rollback pass without changing values outside the declared operation.
7. Security protections are not disabled, directly or indirectly.

Current result: **no benchmark-approved candidate set** (the Competitive preset above makes no performance claim). The catalog contains useful operations with inferred or unverified benefit, but there is not yet enough benchmark evidence to label a combination competitive.

## Benchmark protocol

Each candidate is measured as A/B/A (baseline, candidate, rollback) on the same machine and game/workload build.

- Three warm-up runs, then at least ten recorded runs per state.
- Fixed Windows build, BIOS, firmware, driver versions, power source, display mode, game settings and background workload.
- Reboot whenever an operation declares restart impact; verify the resumed plan before measurement.
- Capture median, p95 and p99 frame time, one-percent low FPS, input-to-present latency when supported by a documented tool, DPC/ISR event counts, packet loss and latency under the same network path.
- Record raw files, tool versions, SHA-256 hashes, timestamps and hardware inventory.
- Reject a candidate when the effect is within run-to-run noise, improves one metric while materially regressing another, or cannot be rolled back exactly/best-effort as declared.
- Event counts and correlations are never presented as causal proof.

## Required matrix

| Dimension | Required | Current evidence |
|---|---:|---|
| Windows 11 Home x64 | Yes | Not available in the existing VM set |
| Windows 11 Pro x64 | Yes | Hyper-V mutation/read-back coverage |
| Intel CPU | Yes | Hyper-V host/guest coverage; hybrid topology not available in guest |
| AMD CPU | Yes | Not available in the existing VM set |
| Intel hybrid CPU | Yes | Not available in the existing VM set |
| AMD GPU | Yes | Not exposed by existing VMs |
| NVIDIA GPU | Yes | Not exposed by existing VMs |
| Intel GPU | Yes | Not exposed by existing VMs |
| Battery / AC | Both | Existing VMs expose AC only |
| MSI, MSI-X, Line-Based PCI | All | Existing VM exposes no allowlisted mutable device |
| English / Italian | Both | Key parity automated; Italian render exercised with the same shell |
| Light / dark, multiple scaling values | All | Persisted system/light/dark modes; automated light/dark render at 150% and 1024×720, broader physical-device matrix pending |

## Approval package

Before owner approval, provide:

- candidate operation IDs and exact desired values;
- evidence level and technical source per operation;
- complete preview and diff;
- raw benchmark archive and summarized confidence/noise;
- apply and rollback journals;
- unsupported-hardware behavior;
- EN/IT screenshots in light/dark themes and tested scaling values;
- an explicit list of excluded security-reducing operations.

Until that package is complete and separately approved, ZapTweaks must not present any profile, Competitive included, as a performance improvement.
