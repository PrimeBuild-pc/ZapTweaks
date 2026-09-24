# TCP Optimizer — implementation handoff

## Requested outcome

Add a fourth tab named **TCP Optimizer** to `Gaming & Prestazioni`, beside Power Settings Explorer, MSI Utility v3/interrupt affinity and Optimizations. The result must look and behave like ZapTweaks, be searchable through the existing global search and be complete in English and Italian.

The product inspiration is:

- repository: <https://github.com/powplowdevs/WINSPAR-Windows-TCP-Optimizer>
- frozen revision: `6392524fcd51925ffe0e082a76facf5b3bb8f322`
- original author/project attribution: `powplowdevs / WINSPAR Windows TCP Optimizer`
- upstream license: **AGPL-3.0**

The user requested an adaptation, but ZapTweaks is MIT and attribution alone does not make copied AGPL code MIT-compatible. Implement the useful behavior clean-room from documented Windows interfaces. Do not copy source, UI code, assets or binaries. Keep a small visible attribution/link in the tab and the complete notice in `THIRD_PARTY_NOTICES.md`.

## Completion record

Implemented on `feat/one-app-plan` as a clean-room native feature:

- live capability-gated global and template TCP inventory, with built-in templates read-only and supported custom/global values editable;
- typed `tcp.setting.configure` and `network.qos.policy` operations with snapshots, read-back verification, helper allowlisting, journal integration and conflict-aware rollback;
- the existing `WindowsRssService` and `network.rss.configure` operation reused for per-adapter RSS controls;
- explicit inventory plus create/edit/delete for only `ZapTweaks - ` QoS policies, with unrelated policies read-only;
- user-supplied direct HTTPS diagnostics bounded to 10 MiB and 30 seconds, cancellable, repeatable, and reported as raw samples plus throughput/latency/jitter/loss;
- EN/IT UI, global-search deep link, and visible attribution to the frozen revision;
- unit/security tests, read-only physical inventory, and a targeted existing-VM TCP/QoS apply/read-back/rollback round trip ending with `CLEAN=true` and the VM off.

No automatic recommendation, daemon, process-priority controller, broad QoS deletion, mutable download-and-execute path, or WINSPAR code/asset/binary was added.

## Current repository state

- Branch: `feat/one-app-plan`.
- Implementation baseline: `940cbac3e9c7a351ea00f25f1e3375e650cb7cd9`.
- Binding specification: `docs/NEW PLAN.md`.
- Milestone ledger: `docs/IMPLEMENTATION_STATUS.md`.
- Current validation: `flutter analyze` clean, 237 tests passing, Windows Release build successful, and the release executable remains running through the startup smoke interval.
- Release executable: `build/windows/x64/runner/Release/ZapTweaks.exe`.
- All 346 legacy IDs remain preserved; the adapted catalog currently has 372 entries.
- Mutating tests may run only in the existing VMs under `D:\VmLab`, through PowerShell Direct and targeted release payloads. Do not mutate the developer's physical machine.

Read `docs/NEW PLAN.md` completely before implementation. The new work remains part of Phase 5 and must use the already implemented operation, Plan Engine, helper, journal and rollback contracts.

## Static upstream audit

The upstream repository was inspected statically only; nothing from it was executed. Relevant files are `Src/TCP optimizer/editor.cpp`, `editor.h`, `CLI.cpp` and `SpeedTest/SpeedTest.py`.

Useful product ideas:

- inspect TCP global state;
- manually configure receive-window autotuning, scaling heuristics, ECN, RSC, RSS and congestion control;
- manage application QoS with DSCP and throttle values;
- run before/after network measurements;
- back up and restore prior TCP state.

Do **not** reproduce these upstream implementation defects:

- localized English `netsh` text is parsed by label;
- the congestion-provider function calls the heuristics command instead of configuring congestion control;
- backup restore never increments its index, so every restored value is sent to RSS;
- startup deletes the complete current-user QoS branch and forces Group Policy refresh;
- “bandwidth usage” is actually process private-memory usage, not network traffic;
- process priority is changed through deprecated WMIC and is unrelated to TCP configuration;
- the automatic optimizer mutates settings sequentially without an exact per-candidate restore and uses inconsistent comparison directions;
- speed testing depends on an external CLI or hard-coded third-party endpoints;
- commands are built from strings and some use `system()`;
- the repository contains prebuilt executables, Java class files and a 40 MiB test payload that must not be vendored.

## Required native scope

### 1. Overview and live state

Show the active TCP state in typed cards, with source and support status. Keep system-global/template TCP settings separate from per-adapter NDIS settings. The existing RSS implementation remains the only per-adapter RSS engine.

Candidate fields must be capability-gated on the current Windows build rather than assumed:

- receive-window autotuning;
- window-scaling heuristics;
- ECN capability;
- receive segment coalescing;
- global RSS state, with a contextual deep link to the existing adapter RSS editor;
- supported congestion-control algorithm/provider per TCP template;
- any additional field only when a documented API/provider returns a typed value and an allowlisted mutation exists.

Never parse localized human-readable output when structured PowerShell objects, CIM, IP Helper APIs, registry value APIs or another locale-independent surface exists.

### 2. Manual configuration

Expose only live-supported values. Each mutation must provide:

- support/capability result;
- readable preview and risk/impact text;
- typed snapshot preserving absent versus present values;
- one helper/UAC plan when elevation is required;
- apply, read-back and verify;
- exact rollback and conflict detection;
- reboot/restart impact when applicable;
- journal evidence and EN/IT strings.

Do not add “optimal”, “gaming”, “recommended” or automatic presets. Presets remain gated by Phase 8 evidence and separate owner approval.

### 3. Application QoS

Provide explicit inventory/create/edit/delete for policies owned or selected by the user. A policy editor may include name, executable identity/path, protocol/ports when supported, DSCP and throttle rate. Validate names, paths, numeric ranges and target scope; do not accept raw command fragments.

Snapshot and restore the exact selected policy. Never clear the parent QoS branch, overwrite unrelated policies, run `gpupdate /force` as a hidden side effect, monitor continuously or throttle other processes automatically. Process priority belongs outside this feature and is excluded.

### 4. Diagnostics and comparison

Offer on-demand, finite measurements for throughput, latency, jitter and packet loss where a trustworthy method is available. The endpoint and network cost must be explicit. Store raw samples and environment metadata sufficient for comparison.

A measurement is diagnostic evidence, not proof that a setting caused an improvement. Do not select or persist a “best” setting from one speed test. If an experimental comparison workflow is added, it must use a declared sequence, exact restoration between candidates, bounded duration, cancellation cleanup and no recommended conclusion.

### 5. Backup, history and recovery

Use ZapTweaks typed snapshots and journal rather than positional plaintext files. The page should link to the existing recovery history for apply/rollback records. Export is optional and should be a typed/versioned JSON report if implemented; do not invent a second backup engine unless required.

## UI and integration

Start with these files:

- `lib/features/power/presentation/gaming_hub_page.dart` — existing tab host;
- `lib/features/power/presentation/power_plans_page.dart` — established native utility UI pattern;
- `lib/features/power/presentation/interrupt_configuration_page.dart` — capability-gated device editor pattern;
- `lib/platform/windows/rss_service.dart` and `lib/core/operations/rss_configuration_operation.dart` — existing per-adapter RSS implementation to reuse/deep-link, not duplicate;
- `lib/core/operations/operation.dart`, `operation_registry.dart`, `native_operation_catalog.dart` — operation contract and registration;
- `lib/core/security/elevated_helper_policy.dart` and `elevated_operation_executor.dart` — helper allowlist/protocol;
- `lib/core/plans/plan_engine.dart` and `lib/core/persistence/operation_store.dart` — execution, journal and rollback;
- `lib/app/zap_tweaks_app.dart` and `lib/app/search_results_page.dart` — navigation/deep links/global search;
- `lib/l10n/app_en.arb`, `lib/l10n/app_it.arb` — mandatory localization.

Prefer a small feature folder such as `lib/features/network/` only if it prevents adding more networking responsibilities to the power feature. Reuse existing services and operation infrastructure; do not create parallel execution, backup or elevation systems.

The tab should contain a modest attribution such as `Inspired by WINSPAR — powplowdevs` linked to the pinned upstream repository. This is attribution, not permission to copy AGPL code.

## Test and acceptance gates

Minimum automatic checks:

- EN/IT key parity and tab/search discoverability;
- structured live-state parsing independent of display language;
- unsupported values rejected before mutation;
- malformed names, executable paths, ports, DSCP and throttle rejected;
- exact snapshot and rollback for present and absent values/policies;
- helper allowlist rejects unknown fields and arbitrary command text;
- QoS delete affects only the selected policy;
- no whole-branch QoS deletion, mutable remote execution, hard-coded speed-test endpoint or bundled upstream payload;
- diagnostics cancel/timeout cleanup;
- Plan Engine journal and conflict behavior.

Windows validation order:

1. read-only inventory on the developer machine if needed;
2. targeted unit tests and `flutter analyze`;
3. mutation/read-back/rollback only in an existing VM under `D:\VmLab`;
4. verify original state is restored and shut down the VM;
5. full `flutter test -j 1` and Windows Release build;
6. manual UI smoke for details, apply preview, diagnostics and recovery in EN/IT, light/dark and constrained window size.

Stop rather than guessing if Windows does not expose a stable typed read-back, exact snapshot or safe rollback for a candidate field.

## Deliverable order for the next session

1. Audit current networking operations/catalog/search and choose the minimum non-duplicating architecture.
2. Implement read-only typed TCP/template and QoS inventory with tests.
3. Add atomic mutation operations, helper allowlist, verification and rollback tests.
4. Add the bilingual TCP Optimizer tab, attribution and global-search deep link.
5. Add bounded diagnostics without automatic recommendations.
6. Perform existing-VM round trips, full gates, update this handoff/status/notices and commit.
