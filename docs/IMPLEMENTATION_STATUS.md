# One App implementation status

This ledger tracks `docs/NEW PLAN.md`. A phase is complete only when its gate is met in production code, not merely by a fixture.

| Phase | Status | Implemented | Remaining gate work |
|---|---|---|---|
| 0 — Baseline | Complete | `assets/catalog/legacy_catalog.json`; 346-ID, uniqueness, destination, disposition and alias tests | — |
| 1 — Shell | Complete | Final navigation, global search, opt-in Expert mode, legacy adapter, external tools retained, no startup UAC, opaque bulk presets hidden | — |
| 2 — Foundations | In progress | Typed operation contract/state/evidence, registry, deterministic Plan Engine, typed snapshots, SQLite v1 journal/reboot tables, conflict-aware privileged rollback, helper allowlist, nonce/hash-bound typed request files, ACL-restricted IPC directory, temporary `runas` helper mode, structured progress stream and native apply/verify/rollback across the elevation boundary; `ui_taskbar_end_task` and `power_throttling_off` now use the Plan Engine and typed Win32 Registry I/O | Route one complete multi-item `OperationPlan` per helper launch instead of one helper call per elevated item |
| 3 — Setup and Apps | In progress | Provider/scope-aware AppX/winget JSON inventory with explicit incomplete-scope reporting and temporary-file cleanup; removal preview model; 17 Microsoft restore operations use verified fixed Store/winget IDs, explicit sources and the Plan Engine | Wizard, elevated all-user/provisioned inventory, optional components, startup and previewed removal operations |
| 4 — Drivers | In progress | Driver identity/rollback model, expiring policy model, HTTPS/hash/publisher verifier, locale-independent Driver Store inventory via PnPUtil XML with deterministic temporary-file cleanup | SetupAPI device correlation, verified install/export rollback and reboot continuation |
| 5 — Gaming and hardware | In progress | Topology-aware RSS, MSI limit and non-truncating affinity validators; native PowrProf scheme enumeration, active-scheme detection, AC/DC value I/O and an exact-snapshot power-setting operation | Migrate fixed catalog entries to PowrProf, VM mutation validation, SetupAPI/IRQ and NDIS platform implementations |
| 6 — Windows and diagnostics | In progress | Cleanup preview scanner, deterministic diagnostic-session lifecycle, and native SCM inspection of live state, start type, delayed start, account, PID and dependencies | SCM mutations, Task Scheduler, ETW collectors, repair and recovery UI |
| 7 — Legacy closure | Not started | — | Replace native-bound scripts, validate aliases, classify composites and move optional payloads on-demand |
| 8 — Profiles | Blocked by approval gate | Legacy bulk controls hidden | Evidence, benchmarks and separate owner approval before any recommended profile |

## Last local verification

- `flutter test -j 1`: 130 tests passed.
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
  elevated-helper protocol; original state was restored, payloads were removed,
  and the VM was shut down.
  No VM or checkpoint was created.
