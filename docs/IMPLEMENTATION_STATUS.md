# One App implementation status

This ledger tracks `docs/NEW PLAN.md`. A phase is complete only when its gate is met in production code, not merely by a fixture.

| Phase | Status | Implemented | Remaining gate work |
|---|---|---|---|
| 0 — Baseline | Complete | `assets/catalog/legacy_catalog.json`; 346-ID, uniqueness, destination, disposition and alias tests | — |
| 1 — Shell | Complete | Final navigation, global search, opt-in Expert mode, legacy adapter, external tools retained, no startup UAC, opaque bulk presets hidden | — |
| 2 — Foundations | Complete | Typed operation contract/state/evidence and registry; deterministic Plan Engine; typed snapshots; SQLite journal/reboot continuation; conflict-aware rollback; nonce/hash-bound, ACL-restricted and allowlisted temporary `runas` helper; one complete elevated multi-item plan per launch with structured progress and helper-side journal; registry/service/power/device lifecycle gate covered | — |
| 3 — Setup and Apps | Complete | Ten-step explicit wizard with inventory, hardware baseline, Windows Update review, SetupAPI driver check, app selection, restorable current-user AppX debloat, interface choice, readable operation preview, Plan Engine execution and final report; provider/scope-aware AppX/winget inventory with one-session elevated all-user/provisioned collection; 464-entry deduplicated app store from pinned CTT/TweakHub, clean-room Winhance candidates and official sources; typed/journaled winget install and previewed multi-uninstall with read-back; AppX removal only after scope/reinstallability preview; optional-feature inventory plus snapshot/apply/verify/rollback; startup inventory with distinct Settings and Task Manager routes; 17 verified Microsoft restore identities | — |
| 4 — Drivers | In progress | Driver identity/rollback model; locale-independent Driver Store inventory via PnPUtil XML; SetupAPI correlation by bound INF then unique hardware identity; signed unbound third-party removal with preview, ACL-protected SHA-256 export and best-effort rollback; local INF install is bound to a selected device and approved INF/catalog hashes plus the Authenticode publisher, then rechecked in the Driver Store; AMD/NVIDIA/Intel flows open only official sources; reboot continuations are reverified only after a detected Windows reboot; the documented Windows Update driver exclusion can be paused for 7/30 days with an expiry reminder and exact previous-value restoration | Validate local install/removal in an existing VM |
| 5 — Gaming and hardware | In progress | Topology-aware RSS, MSI limit and non-truncating affinity validators; native processor-group and NUMA topology inventory; provider-backed NDIS RSS inspection/mutation with complete tuple snapshots, live topology/range validation and no registry fallback; a real VM disable/read-back/restore round trip exposed and fixed disabled-provider queue limits by re-enabling before live validation, then restored the complete tuple; SetupAPI reads documented PCI Line/MSI/MSI-X support and hardware message maxima, while a typed operation limits changes to present display/network/media devices and snapshots MSI values exactly; explicit interrupt affinity is limited to representable group-0 masks, validated against live topology and snapshotted without truncation; native PowrProf scheme enumeration, active-scheme detection, AC/DC value I/O, duplication, rename and guarded deletion; the bilingual power-plan UI provides list, search, complete setting metadata (including entries hidden by Windows without changing registry visibility), AC/DC comparison and exact-snapshot activation; processor boost mode and maximum processor state route through PowrProf operations; real VM round trips changed AC maximum processor state and duplicated/renamed/activated/deleted a scheme, then restored the original values and active scheme; `.pow` import/export uses `powercfg` only for the missing PowrProf file APIs, verifies non-empty exports, bounds imports to 64 MiB, freezes and hashes input against TOCTOU, and verifies exactly one new scheme; bilingual native file-dialog import/export and exact-snapshot rename and backup-before-delete are exposed in the UI, and imports use an app-assigned GUID plus an exact rollback operation | Complete remaining management and fixed-setting migrations, validate MSI and interrupt-affinity mutation/rollback when an existing VM exposes an allowlisted PCI display/network/media device (the current Hyper-V VM exposes none, so the capability gate correctly refused mutation), then add the remaining hardware-specific UI |
| 6 — Windows and diagnostics | In progress | Cleanup preview scanner, deterministic diagnostic-session lifecycle, native SCM inspection of live state/start type/delayed start/account/PID/dependencies, allowlisted exact-snapshot SCM startup mutation without silently stopping a running service, and allowlisted Task Scheduler enable/disable with typed read-back and exact rollback, bounded on-demand WPR/ETW capture exposed through the bilingual recovery UI and elevated plan; it always stops, verifies a non-empty local trace and leaves no resident monitor, and fixed DISM/SFC repair flows exposed through a bilingual recovery UI, with explicit non-reversible confirmation, one elevated plan, a bounded two-hour repair-helper ceiling, and separate health verification before success; the hardware monitor performs one-shot, non-resident dedicated-VRAM and ACPI thermal-zone reads, rejects physically invalid temperatures, and does not mislabel firmware zones as CPU/GPU sensors | ETW/DPC analysis and report interpretation |
| 7 — Legacy closure | Not started | — | Replace native-bound scripts, validate aliases, classify composites and move optional payloads on-demand |
| 8 — Profiles | Blocked by approval gate | Legacy bulk controls hidden | Evidence, benchmarks and separate owner approval before any recommended profile |

## Last local verification

- `flutter test -j 1`: 191 tests passed.
- `flutter analyze`: no issues.
- `flutter build windows --debug` and `--release`: succeeded.
- The main executable starts as `asInvoker`; real UAC helper smoke tests
  rejected unknown operations without mutation and returned typed failures.
  Requests are now SHA-256-bound to the approved payload. Helper waits have a
  five-minute termination ceiling, except explicitly identified DISM/SFC repair
  plans, which have a finite two-hour ceiling.
- The `1280x820` app window was observed centered on the primary display after
  startup with a secondary display using negative bounds.
- Existing Hyper-V VM `D:\VmLab\NeuroTune-W11` passed a real helper mutation
  and read-back for `network_ecn_disabled`, plus typed Win32 Registry
  inspect/snapshot/apply/verify/rollback round trips preserving raw DWORD bytes.
  Provider-backed RSS inventory was also parsed successfully in the VM for its
  Hyper-V Ethernet adapter without mutation. The latest round trips exercised
  `power_throttling_off` through the native
  elevated multi-item plan protocol, the temporary Windows Update driver
  exclusion, and PowrProf maximum processor state AC/DC mutation. Each was read
  back and restored from a typed snapshot. A real five-second WPR smoke capture
  also produced a non-empty 15,728,640-byte ETL, then removed the trace and
  payload. Original state was restored and the VM was shut down.
  No VM or checkpoint was created.
