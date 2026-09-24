# Competitive profile evidence gate

No competitive profile is published or recommended. This file defines the evidence and benchmark package required before the separate owner approval in Phase 8.

## Candidate operation policy

An operation may enter a candidate profile only when all of these are true:

1. It is present in the typed native operation catalog; legacy scripts, shell commands and external tools are excluded.
2. `mechanismEvidence` and `valueEvidence` are `documented` or `runtimeObserved`.
3. `benefitEvidence` is not `unverified`.
4. Live capability checks pass on the target machine.
5. The preview identifies the operation ID, target, desired value, restart impact and rollback capability.
6. Apply, read-back verification and rollback pass without changing values outside the declared operation.
7. Security protections are not disabled, directly or indirectly.

Current result: **no approved candidate set**. The catalog contains useful operations with inferred or unverified benefit, but there is not yet enough benchmark evidence to label a combination competitive.

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

Until that package is complete and separately approved, ZapTweaks must keep recommended competitive profiles absent.
