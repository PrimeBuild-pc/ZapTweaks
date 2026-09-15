# One App implementation status

This ledger tracks `docs/NEW PLAN.md`. A phase is complete only when its gate is met in production code, not merely by a fixture.

| Phase | Status | Implemented | Remaining gate work |
|---|---|---|---|
| 0 — Baseline | Complete | `assets/catalog/legacy_catalog.json`; 346-ID, uniqueness, destination, disposition and alias tests | — |
| 1 — Shell | Complete | Final navigation, global search, opt-in Expert mode, legacy adapter, external tools retained, no startup UAC, opaque bulk presets hidden | — |
| 2 — Foundations | Complete | Typed operation contract/state/evidence and registry; deterministic Plan Engine; typed snapshots; SQLite journal/reboot continuation; conflict-aware rollback; nonce/hash-bound, ACL-restricted and allowlisted temporary `runas` helper; one complete elevated multi-item plan per launch with structured progress and helper-side journal; registry/service/power/device lifecycle gate covered | — |
| 3 — Setup and Apps | Complete | Ten-step explicit wizard with inventory, hardware baseline, Windows Update review, SetupAPI driver check, app selection, restorable current-user AppX debloat, interface choice, readable operation preview, Plan Engine execution and final report; provider/scope-aware AppX/winget inventory with one-session elevated all-user/provisioned collection; 464-entry deduplicated app store from pinned CTT/TweakHub, clean-room Winhance candidates and official sources; typed/journaled winget install and previewed multi-uninstall with read-back; AppX removal only after scope/reinstallability preview; optional-feature inventory plus snapshot/apply/verify/rollback; startup inventory with distinct Settings and Task Manager routes; 17 verified Microsoft restore identities | — |
| 4 — Drivers | In progress | Driver identity/rollback model, expiring policy model, HTTPS/hash/publisher verifier, locale-independent Driver Store inventory via PnPUtil XML; SetupAPI devices correlate to Driver Store packages by bound published INF then unique hardware identity; Driver UI exposes signed package metadata and blocks bound/Microsoft packages; removal runs only after preview and creates an ACL-protected, SHA-256-manifested export for best-effort rollback; declared reboot impact persists continuation | Verified local install flow and vendor-assisted AMD/NVIDIA/Intel flows |
| 5 — Gaming and hardware | In progress | Topology-aware RSS, MSI limit and non-truncating affinity validators; native PowrProf scheme enumeration, active-scheme detection, AC/DC value I/O and an exact-snapshot power-setting operation | Migrate fixed catalog entries to PowrProf, VM mutation validation, SetupAPI/IRQ and NDIS platform implementations |
| 6 — Windows and diagnostics | In progress | Cleanup preview scanner, deterministic diagnostic-session lifecycle, and native SCM inspection of live state, start type, delayed start, account, PID and dependencies | SCM mutations, Task Scheduler, ETW collectors, repair and recovery UI |
| 7 — Legacy closure | Not started | — | Replace native-bound scripts, validate aliases, classify composites and move optional payloads on-demand |
| 8 — Profiles | Blocked by approval gate | Legacy bulk controls hidden | Evidence, benchmarks and separate owner approval before any recommended profile |

## Last local verification

- `flutter test -j 1`: 152 tests passed.
- `flutter analyze`: no issues.
- `flutter build windows --debug` and `--release`: succeeded.
- The main executable starts as `asInvoker`; real UAC helper smoke tests
  rejected unknown operations without mutation and returned typed failures.
  Requests are now SHA-256-bound to the approved payload and helper waits have
  a five-minute termination ceiling.
- The `1280x820` app window was observed centered on the primary display after
  startup with a secondary display using negative bounds.
- Existing Hyper-V VM `D:\VmLab\NeuroTune-W11` passed a real helper mutation
  and read-back for `network_ecn_disabled`, plus typed Win32 Registry
  inspect/snapshot/apply/verify/rollback round trips preserving raw DWORD bytes.
  The latest round trip exercised `power_throttling_off` through the native
  elevated multi-item plan protocol, persisted its helper-side journal, then
  rolled back from the returned typed snapshot; original state was restored,
  payloads were removed,
  and the VM was shut down.
  No VM or checkpoint was created.
