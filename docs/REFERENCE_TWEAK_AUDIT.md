# Reference tweak audit

This records the clean-room intake requested for WinUtil and Windows 11 Fix Tweaks. The operation contract in `docs/NEW PLAN.md` remains authoritative.

## Frozen inputs

| Source | Revision | Reviewed artifact | SHA-256 |
|---|---|---|---|
| CTT WinUtil | `a0d3c719a6611b329422e9c56ee9b792cd596146` | `config/tweaks.json` | `86f07e190a87e2f0ed2143e5266527ca2ebe00712cf5242db1fe20105600d2c2` |
| CTT WinUtil | same | `config/applications.json` | `b1fd87ca26504919f564b6a9d885d56de626b9d72fd2eaabd5d2b6bcf3ad0a35` |
| Windows 11 Fix Tweaks by kubaam | `8da4fe0251f3c46aec6434e38e7a92f06307313a` | `Win11_AllInOneTweaks.bat` | `12d257371e49f18f0a0d7b98ee1e48d5bdd116ce136af322f9cbfa24aed9e37e` |

Both projects declare MIT licenses at these revisions.

## Integrated now

- WinUtil's 233 application references are normalized into `assets/catalog/app_catalog.json`; duplicate winget identities merge with TweakHub and clean-room Winhance candidates.
- Existing ZapTweaks controls already cover individual WinUtil families including Game Mode, MPO, mouse acceleration, file extensions, hidden files, taskbar controls, privacy, Delivery Optimization, hibernation, power plans, repair, Store/AppX recovery, and network diagnostics.
- `ui_taskbar_end_task` uses the typed native registry operation rather than WinUtil's script path.
- CTT WinUtil remains reachable as `CTT WinUtil by Chris Titus Tech`, but only through its official releases page. Mutable `irm URL | iex` execution is intentionally blocked.
- Windows 11 Fix Tweaks remains reachable as `Windows 11 Fix Tweaks by kubaam` at the frozen source revision.

## Not imported as executable tweaks

The Windows 11 Fix Tweaks batch includes an unprompted "Apply ALL Recommended Tweaks" path and composites for BCDEdit timers, TCP/IP reset, debloat, service changes, cache deletion, security policy, and registry backup. Importing that batch would bypass live capability checks, typed snapshots, per-item verification, journal, and exact rollback. It is therefore a reference, not an executable payload.

WinUtil composites are treated the same way. Individual mechanisms may be migrated only as typed operations in plan order; overlapping cards are not duplicated.

## Deferred to the binding phases

- Optional Windows components, startup inventory, and previewed AppX removal: implemented in Phase 3.
- Driver actions: Phase 4.
- Power, NDIS/RSS, MSI/MSI-X, and affinity: Phase 5.
- Service/task mutations, DISM/SFC, cleanup, ETW, and recovery: Phase 6.
- Remaining remote and opaque legacy scripts: Phase 7.
