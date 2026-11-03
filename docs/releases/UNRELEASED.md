# ZapTweaks: next release (not released yet)

Changes merged after v1.13.0. They are kept for a larger release; rename this file to `vX.Y.Z.md` when the version is tagged.

## Gaming & Performance

- New "Defender exclusion" tab: excludes the folder of one game from Microsoft Defender real-time scanning. Manual only (never in a preset or in Guided setup), with a fixed note in every language: "May reduce loading times; the effect on FPS is not proven." Windows, ProgramData, everything under the user profiles (AppData, Startup, Desktop, Documents, Downloads), Temp, the Defender and Windows folders inside Program Files, drive roots, network paths and links are refused; launcher or library folders need a second confirmation. ZapTweaks lists the exclusions it added, each with Remove, and shows a reminder above every Gaming tab while one exists. It works only when Defender is the active antivirus with real-time protection on and no policy ignores local exclusions.
- Interrupts: "Suggested layout by role" gives graphics, USB, network and audio one physical core each, outside core 0, chosen from the CPU topology (P-cores only on hybrid Intel CPUs; on dual-CCD Ryzen the CCD without 3D V-Cache, or the second one when the caches are equal; network and audio share a core on CPUs with 6 cores or fewer). A preview shows what is to do, already set or skipped. Only the interrupt affinity changes, with the usual per-device rollback. RSS of the network adapter is shown but not moved, because Windows also changes its queues and processors and that cannot be undone exactly. The audio core goes only to a sound card in use: the HDMI/DisplayPort audio of the graphics card and controllers whose audio devices are all disabled are skipped, and when none is left the preview explains that USB audio (headsets, DACs, audio interfaces) follows its USB controller's core.

## App store

- New entries: NVIDIA VBIOS Vix Editor (GPU & Display) and AMD-NR (OptiScaler) (Gaming & Input), with requirements and warnings. Catalog revision 2026110301.
