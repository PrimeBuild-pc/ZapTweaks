# One App implementation status

This ledger tracks `docs/NEW PLAN.md`. A phase is complete only when its gate is met in production code, not merely by a fixture.

| Phase | Status | Implemented | Remaining gate work |
|---|---|---|---|
| 0 — Baseline | Complete | `assets/catalog/legacy_catalog.json`; 346-ID, uniqueness, destination, disposition and alias tests | — |
| 1 — Shell | Complete | Final navigation, global search, opt-in Expert mode, legacy adapter, external tools retained, no startup UAC, opaque bulk presets hidden | — |
| 2 — Foundations | In progress | Typed operation contract/state/evidence, registry, deterministic Plan Engine, typed snapshots, SQLite v1 journal/reboot tables, conflict-aware rollback, helper allowlist policy | Connect a signed native temporary helper and route production mutations through the engine |
| 3 — Setup and Apps | In progress | Provider/scope-aware app inventory parser, removal preview model, 17 Microsoft restore identities | Native wizard and mutation operations through Plan Engine |
| 4 — Drivers | In progress | Driver identity/rollback model, expiring policy model, HTTPS/hash/publisher verifier | SetupAPI/Driver Store inventory and verified install/reboot continuation |
| 5 — Gaming and hardware | In progress | Topology-aware RSS, MSI limit and non-truncating affinity validators | PowrProf, SetupAPI/IRQ and NDIS platform implementations |
| 6 — Windows and diagnostics | In progress | Cleanup preview scanner and deterministic diagnostic-session lifecycle | SCM, Task Scheduler, ETW collectors, repair and recovery UI |
| 7 — Legacy closure | Not started | — | Replace native-bound scripts, validate aliases, classify composites and move optional payloads on-demand |
| 8 — Profiles | Blocked by approval gate | Legacy bulk controls hidden | Evidence, benchmarks and separate owner approval before any recommended profile |

## Last local verification

- `flutter test -j 1`: 99 tests passed.
- `flutter analyze`: no issues.
- `flutter build windows --debug`: succeeded.
