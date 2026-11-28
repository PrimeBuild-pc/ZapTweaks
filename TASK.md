# TASK — ZapTweaks

> Documento di specifica approvato il 23/10/2026.
> Fonte delle decisioni: `HANDOFF.md` e matrice di roadmap approvata.
> **Stato:** task documentati e approvati come direzione; **nessuna implementazione autorizzata**.
> Le modifiche a codice, configurazioni, script, test o preset richiedono una nuova autorizzazione esplicita.

## Regole comuni

- Non creare commit, branch o PR senza autorizzazione di Lorenzo.
- Non toccare il WIP esistente del branch `feat/apps-services-presets`.
- Ogni task è incrementale e deve poter essere consegnato e verificato da solo.
- Non introdurre un engine generale o un refactoring globale come prerequisito dei fix P0.
- Le task possono usare le operazioni tipizzate esistenti (`lib/core/operations/*`) o un adapter sottile; l'implementazione interna resta libera.
- Non dichiarare un'operazione reversibile se il ripristino completo non è garantito.
- Distinguere sempre: esito dell'operazione, stato configurato, stato effettivo, vincoli esterni/policy, possibilità di rollback. Non comprimere queste dimensioni in un unico stato ambiguo.
- Le prove devono includere casi con valori assenti, valori personalizzati, modifiche esterne, errori parziali, rollback non eseguibile, policy e stato sconosciuto.
- Etichette di analisi: `VERIFICATO`, `INFERITO`, `DA VALIDARE`, `NON ACCESSIBILE`.
- Controlli del progetto: `flutter analyze`, `flutter test`. Il test noto che fallisce solo in shell elevata va distinto dai fallimenti reali.
- Dopo modifiche al codice: `graphify update .`.

## Contratto minimo di rollback — modello condiviso

Questo modello è parte di `ZT-RB-00` e va usato da tutti i task che applicano modifiche.

### Dimensioni indipendenti

| Dimensione | Valori ammessi | Significato |
|---|---|---|
| Esito operazione | `applied`, `already_applied`, `partial`, `failed`, `skipped`, `cancelled` | Cosa è successo durante l'esecuzione. |
| Stato configurato | `configured`, `not_configured`, `unknown` | Il valore/la configurazione è stata scritta o è assente/illeggibile. |
| Stato effettivo | `effective`, `not_effective`, `unknown`, `not_applicable` | Windows sta realmente applicando il comportamento atteso. |
| Vincolo esterno | `none`, `policy_managed`, `locked`, `unsupported_build`, `permission_denied`, `external_change` | Un'autorità esterna può impedire o modificare il risultato. |
| Rollback | `exact`, `best_effort`, `unavailable`, `not_attempted`, `incomplete`, `manual_required` | Grado di ripristino realmente disponibile. |

Un risultato può essere, per esempio, `configured=configured`, `effective=unknown`, `external=policy_managed`, `rollback=unavailable`. Non va ridotto a “successo” o “fallito”.

### Requisiti minimi

- **Snapshot prima della mutazione:** esistenza, tipo, valore, hive e vista 32/64, indicazione policy, owner/baseline, build OS, timestamp. Per elementi non-registro registrare lo stato equivalente pertinente.
- **Valori inizialmente inesistenti:** lo snapshot registra `exists=false`; il rollback elimina solo se il valore corrente è ancora quello scritto dal task e non è stato modificato da altri.
- **Valori modificati da altri tweak:** confrontare con la baseline/ownership; se il valore non corrisponde, non sovrascrivere. Riportare `external_change` o conflitto.
- **Apply/verifica:** preflight, snapshot, apply, verifica. Se lo stato effettivo non è leggibile, riportare `configured`/`unknown`, non `applied`.
- **Fallimenti parziali:** annullare in ordine inverso le operazioni già applicate. Se il rollback fallisce, riportare `incomplete` o `manual_required` e conservare le informazioni di recupero.
- **Interruzioni:** prevedere un punto di estensione per journal persistente e recovery, ma implementarli solo quando un'operazione attraversa processi/riavvio o quando il rischio lo giustifica.
- **Locking:** prevedere un'interfaccia per lock per chiave/valore; implementarla solo quando esiste un percorso concorrente reale o una gara dimostrata.
- **Rollback non eseguibile:** mostrare `manual_required`, percorso del backup e istruzioni; nessun messaggio di revert riuscito.
- **AppX/script:** classificare `one_way` o `best_effort`; richiedere conferma esplicita; non promettere reinstallazione o ripristino completo se non è disponibile una fonte verificata.
- **Policy:** rilevare `policy_managed` o `locked`; non aggirare la policy e non proporre un revert che Windows riapplicherebbe.
- **Stato sconosciuto:** riportare `unknown`; non trattarlo come “non applicato” o “riuscito”.

## P0 — prerequisito e sicurezza

### ZT-RB-00 — Contratto minimo di rollback

**Priorità:** P0
**Dipendenze:** nessuna
**Obiettivo:** definire il contratto minimo condiviso per snapshot, apply, verifica, rollback e fallimenti parziali, con un adapter di riferimento sufficiente per i fix P0.

**In scope**
- Modello delle cinque dimensioni indipendenti descritto sopra.
- Struttura minima di snapshot e risultato.
- Sequenza preflight → snapshot → apply → verifica → rollback.
- Regole per valori assenti, modifiche esterne, policy, rollback non eseguibile e operazioni one-way.
- Punti di estensione per journal persistente, locking e recovery, senza obbligo di implementarli subito.
- Un adapter di riferimento per il registro, riutilizzabile dai task P0.

**Out of scope**
- Un engine generale di transazioni.
- Journal persistente, locking distribuito o recovery automatico non richiesti da un caso concreto.
- Refactoring completo del catalogo.
- Modifiche UI oltre a quanto serve per rappresentare gli stati.

**Requisiti**
- Il contratto deve poter essere usato da `ZT-SYS-01`, `ZT-PRV-01` e `ZT-VBS-01` senza riscriverlo.
- Le cinque dimensioni non devono collassare in un singolo enum o in un booleano.
- Il journal persistente deve essere un'estensione prevista, non un prerequisito per i fix P0.
- Il locking deve essere un punto di estensione, non un'implementazione anticipata.
- Gli script possono essere usati solo con backup esplicito o dichiarazione `one_way`/`best_effort`.
- Il contratto deve essere compatibile con le operazioni tipizzate esistenti e con il loro modello di evidence/rollback.

**Criteri di accettazione**
- Esistono test o prove per: valore assente, valore esistente personalizzato, modifica esterna, apply parziale, rollback riuscito, rollback fallito, policy bloccante, stato effettivo sconosciuto.
- Un risultato parziale non può essere presentato come successo.
- Un'operazione senza ripristino completo riporta `rollback=unavailable` o `manual_required`.
- I task P0 possono consumare il contratto senza attendere un engine generale.
- La documentazione del contratto è breve e verificabile; le estensioni future sono elencate, non implementate.

**Prove minime**
- Test unitari del modello di risultato e dell'adapter.
- Casi di rollback con valore originale assente e con valore originale presente.
- Caso di valore cambiato da un altro attore tra apply e rollback.

**Nota di scope**
`ZT-RB-00` non deve bloccare i fix P0. La sua prima consegna è il contratto più l'adapter minimo; tutto il resto è estensione successiva.

### ZT-SYS-01 — Rollback e stato effettivo dei System Checks

**Priorità:** P0
**Dipendenze:** `ZT-RB-00`
**Obiettivo:** rendere firewall, UAC, Spectre/Meltdown, DEP e memory compression reversibili, verificabili e non ingannevoli.

**In scope**
- `checks_firewall_off`
- `checks_uac_off`
- `checks_spectre_meltdown_off`
- `checks_dep_off`
- `checks_memory_compression_off`
- Stati configured/effective/policy/unknown e rollback exact/one-way.
- Messaggi di rischio e stato nella UI esistente, senza ridisegnare la pagina.

**Out of scope**
- VBS/HVCI, coperto da `ZT-VBS-01`.
- Nuovi tweak di sicurezza non elencati.
- Disattivazioni silenziose o preset che includono questi check.
- Modifiche al comportamento di Windows Security oltre a quanto necessario per rilevare lo stato.

**Requisiti**
- Non usare `ControlSet001` per scrivere lo stato corrente; usare la via supportata o un'operazione tipizzata.
- Salvare i valori originali, inclusi i valori assenti e quelli non standard.
- Ripristinare il valore originale, non un default hardcoded.
- Verificare lo stato effettivo quando è leggibile; altrimenti riportare `unknown`.
- Rilevare policy/`Locked` e non tentare di aggirarle.
- Se il rollback completo non è possibile, dichiararlo e non mostrare un toggle come reversibile.
- Gestire i profili firewall in modo completo; non limitarsi a Public/Standard se il comportamento globale è interessato.
- Per DEP e memory compression, gestire il caso in cui il valore originale non esista o sia gestito da policy.

**Criteri di accettazione**
- Nessun nuovo uso di `ControlSet001` per lo stato corrente.
- Per ogni check: valore assente, valore originale personalizzato, apply, verifica, rollback exact.
- Un apply parziale non restituisce successo.
- Policy bloccante e stato sconosciuto sono visibili e non vengono trattati come “disattivato”.
- Test per firewall, UAC, Spectre, DEP e memory compression.
- `flutter analyze` e `flutter test` puliti, escluso il test noto in shell elevata.

### ZT-PRV-01 — Rollback completo della privacy esistente

**Priorità:** P0
**Dipendenze:** `ZT-RB-00`
**Obiettivo:** rendere reversibili e verificabili i valori privacy/telemetria già applicati da ZapTweaks.

**In scope**
- `_applyPrivacyTracking` e i valori che applica.
- Valori assenti, valori non standard, modifiche esterne, policy e rollback non eseguibile.
- Stato configured/effective e indicazione di eventuali valori one-way.
- GameBar/GameDVR esclusi: passano a `ZT-GDV-01`.

**Out of scope**
- Nuovo catalogo privacy o nuovi profili.
- GameBar, cattura, overlay e pacchetto Xbox.
- Modifiche a TweakHub.
- Preset privacy.

**Requisiti**
- Ogni valore applicato deve avere uno snapshot e un percorso di ripristino, oppure una dichiarazione esplicita `one_way`.
- Non impostare `SyncPolicy=1` come presunto default: ripristinare lo stato originale o dichiarare l'operazione non reversibile.
- Ripristinare anche i valori attualmente non coperti dal revert, se sono stati modificati dal tweak.
- Rilevare i valori gestiti da policy e non combatterli.
- Non duplicare la logica GameBar: rimuoverla dal perimetro privacy o delegarla a `ZT-GDV-01` con un unico owner.
- La UI deve mostrare chiaramente quando il ripristino è parziale o non disponibile.

**Criteri di accettazione**
- Matrice dei valori con: esistente, assente, personalizzato, policy, apply, verify, rollback.
- Nessun valore applicato resta senza esito o senza dichiarazione `one_way`.
- Un errore su un valore non viene ignorato e non produce successo globale.
- Test dedicati per i valori orfani del revert attuale.
- Nessuna regressione sui toggle privacy non toccati.
- `flutter analyze` e `flutter test` puliti, escluso il test noto in shell elevata.

### ZT-VBS-01 — Consolidamento VBS/HVCI

**Priorità:** P0
**Dipendenze:** `ZT-RB-00`
**Obiettivo:** eliminare le rappresentazioni duplicate e incoerenti di VBS/HVCI, distinguendo configurazione, stato effettivo e policy.

**In scope**
- `checks_core_isolation_off`
- `checks_vbs_off`
- `SparkleHvciConfiguredOperation`
- Stato configured/effective, policy/`Locked`, rollback exact/one-way.
- Un solo modello di dominio per VBS/HVCI.

**Out of scope**
- Bypass di policy o `Locked`.
- Disattivazione automatica nei preset.
- Modalità esperta TweakHub, che è `TH-VBS-01`.
- Nuove tecniche di disattivazione non supportate.

**Requisiti**
- Un solo owner concettuale per VBS/HVCI; niente tre voci con semantiche diverse.
- Rilevare policy e `Locked` prima di qualsiasi scrittura.
- Distinguere “configurato” da “effettivo”; se non è possibile verificare, riportare `unknown`.
- Ripristinare i valori originali o dichiarare l'operazione one-way.
- Non usare `ControlSet001` per lo stato corrente.
- La UI deve spiegare il rischio di sicurezza e non promettere un revert se la policy lo impedisce.

**Criteri di accettazione**
- Una sola rappresentazione VBS/HVCI nel catalogo e nella UI.
- Test per: VBS attivo, VBS disattivato, policy bloccante, `Locked`, valore assente, valore personalizzato.
- Nessuna scrittura quando la policy blocca.
- `configured=configured` non viene mostrato come `effective=effective`.
- Rollback exact o dichiarazione esplicita.
- `flutter analyze` e `flutter test` puliti, escluso il test noto in shell elevata.

## P1 — affidabilità e domini principali

### ZT-RB-01 — Migrazione del catalogo legacy/script al contratto

**Priorità:** P1
**Dipendenze:** `ZT-RB-00`, `ZT-SYS-01`, `ZT-PRV-01`
**Obiettivo:** applicare il contratto di rollback ai tweak legacy/script con ripristino non esatto, privilegiando i percorsi realmente live e le operazioni distruttive.

**In scope**
- Metodi `_apply*` legacy ancora raggiungibili.
- Script toggle e `PowerShellStateTweak`.
- Conflitti tra tweak che scrivono la stessa chiave.
- Operazioni AppX distruttive (`CopilotTweak`, `SafeDebloatPreset`).
- Errori di registro attualmente ingoiati da `TweakManager`.

**Out of scope**
- Riscrittura integrale del catalogo in un unico passaggio.
- Engine generale o journal persistente non giustificato.
- Tweak legacy bloccati da `OperationRegistry` senza percorso live verificato.
- Nuovi tweak non presenti nel catalogo approvato.

**Requisiti**
- Procedere per famiglie di tweak, con consegne indipendenti.
- Preferire operazioni tipizzate + journal; usare script con backup esplicito quando appropriato.
- Ripristinare i valori originali, inclusi i casi assenti e personalizzati.
- Non ignorare gli errori di registro: un fallimento parziale deve essere visibile.
- Dichiarare `one_way` le rimozioni AppX non reversibili; non usare un toggle “revert” ingannevole.
- Rilevare e dichiarare i conflitti tra profili AMD, GameDVR/FSE e tweak che condividono chiavi.
- Verificare il percorso live prima di modificare codice legacy bloccato.

**Criteri di accettazione**
- `ContextMenuCleanTweak` ripristina `pintohome`/`pintohomefile` o dichiara `one_way`.
- `StartMenuTaskbarCleanTweak` non elimina l'intera chiave `Windows Feeds` e ripristina i valori originali.
- `NetworkLowLatencyBandwidthProfileTweak` salva lo stato originale o dichiara il rollback `best_effort`/`unavailable`.
- `NetworkMmAgentTweak` ripristina `MemoryCompression` e non usa default hardcoded non verificati.
- `AmdUlpsOff` ripristina il valore originale, non sempre `1`.
- `CopilotTweak` e `SafeDebloatPreset` sono esplicitamente one-way e non promettono reinstallazione.
- `TweakManager` propaga gli errori di registro e non riporta successo dopo un'eccezione.
- Test per almeno una famiglia registry, una script e una AppX.
- `flutter analyze` e `flutter test` puliti, escluso il test noto in shell elevata.

**Nota**
Non è richiesto correggere tutto il legacy in un unico task. Il task è completo quando il contratto è applicato alle famiglie prioritarie e il resto è tracciato con ID o note esplicite.

### ZT-GDV-01 — GameDVR canonico in ZapTweaks

**Priorità:** P1
**Dipendenze:** `ZT-RB-00`
**Obiettivo:** definire un unico modello GameDVR per cattura, overlay, hotkey e avvio, senza duplicare la privacy e senza promesse non verificate.

**In scope**
- `GameDVR_Enabled`, `AppCaptureEnabled`, `HistoricalCaptureEnabled`, `AudioCaptureEnabled`, `ShowStartupPanel`.
- `UseNexusForGameBarEnabled`, `GamepadNexusChordEnabled`.
- Hotkey `VK*` e comportamento di avvio.
- Policy `AllowGameDVR` e stato effettivo.
- Stato configured/effective/policy e rollback exact/one-way.

**Out of scope**
- `AutoGameModeEnabled`: non appartiene a GameDVR.
- Rimozione del pacchetto Xbox Game Bar: opzionale e fuori dal MVP.
- Preset GameDVR: `ZT-GDV-02`.
- Nuovi tweak GameDVR non approvati.
- Promesse di FPS, latenza o benefici non misurati.

**Requisiti**
- Un solo owner per GameDVR; `ZT-PRV-01` non deve duplicarlo.
- Separare cattura, overlay, hotkey e avvio: un unico toggle non deve nascondere effetti diversi.
- Salvare e ripristinare i valori originali; gestire valori assenti e policy.
- Validare l'efficacia sulle build supportate; se non è possibile, riportare `effective=unknown`.
- Non rimuovere pacchetti nel MVP.
- Non usare `AutoGameModeEnabled` come scorciatoia.
- La UI deve descrivere cosa viene disattivato e cosa resta attivo.

**Criteri di accettazione**
- GameBar/GameDVR non è più duplicato in privacy.
- Test per valori assenti, valori personalizzati, policy, apply parziale e rollback.
- Matrice build con stato supportato/non supportato/unknown.
- Nessuna promessa di FPS/latenza.
- Nessuna rimozione pacchetto nel MVP.
- `flutter analyze` e `flutter test` puliti, escluso il test noto in shell elevata.

## P2 — copertura, preset e rilevamento

### ZT-BEN-01 — Estensione di build applicability e conflitti

**Priorità:** P2
**Dipendenze:** `ZT-RB-01`, `ZT-GDV-01`
**Obiettivo:** estendere i metadati già esistenti (`minimumWindowsBuild`, `conflictingTweakIds`) senza introdurre un nuovo framework.

**In scope**
- Copertura build per GameDVR, VBS, tweak legacy e script.
- Conflitti tra profili AMD, GameDVR/FSE, privacy e tweak che condividono chiavi.
- Comportamento per build sconosciuta o non supportata.
- Uso dei metadati da parte delle nuove funzionalità.

**Out of scope**
- Nuovo sistema di metadati.
- Refactoring globale del catalogo.
- Modifiche alla UI oltre a nascondere/marcare le voci non applicabili.

**Requisiti**
- Riutilizzare i campi esistenti; estendere solo la copertura.
- Le nuove funzionalità devono consultare i metadati fin dall'inizio, non solo dopo la conclusione del task.
- Build sconosciuta: non assumere supporto; mostrare `unknown` o richiedere conferma.
- Conflitti: dichiararli e impedire combinazioni non sicure.
- Test per build minima, build superiore, build sconosciuta e conflitto.

**Criteri di accettazione**
- Almeno GameDVR, VBS e i profili AMD hanno metadati di build/conflitto verificabili.
- Una combinazione conflittuale viene rilevata prima dell'apply.
- Nessun nuovo framework di metadati.
- Test e `flutter analyze`/`flutter test` puliti, escluso il test noto in shell elevata.

### ZT-GDV-02 — Preset GameDVR opt-in

**Priorità:** P2
**Dipendenze:** `ZT-GDV-01`
**Obiettivo:** offrire un preset GameDVR solo su scelta esplicita, dopo la validazione del modello e delle build.

**In scope**
- Preset opt-in, non attivo per default.
- Descrizione chiara di cattura, overlay, hotkey, avvio e riavvio.
- Rollback esatto o dichiarazione one-way.

**Out of scope**
- Preset automatici o silenziosi.
- Rimozione pacchetto.
- Promesse di prestazioni.

**Criteri di accettazione**
- Il preset non è attivo per default.
- La UI mostra cosa cambia e cosa resta attivo.
- Il rollback è verificato o dichiarato non disponibile.
- Nessuna promessa FPS/latenza.

### ZT-VBS-02 — Rilevamento read-only VBS/HVCI

**Priorità:** P2
**Dipendenze:** `ZT-VBS-01`
**Obiettivo:** esporre lo stato VBS/HVCI in sola lettura, senza scritture.

**In scope**
- Lettura via CIM/strumenti supportati.
- Stato configured/effective/policy/unknown.
- Etichette e spiegazioni.

**Out of scope**
- Disattivazione, bypass o modifica di policy.
- Modalità esperta.

**Criteri di accettazione**
- Nessuna scrittura durante il rilevamento.
- Test per VBS attivo, disattivato, policy, unknown.
- La UI non suggerisce che il solo rilevamento sia un fix.

## Dipendenze cross-project

- `X-PRIV-01` è canonico in `TweakHub/TASK.md`: matrice di ownership e registro delle chiavi.
- I fix P0 di ZapTweaks possono procedere senza attendere la matrice completa, ma ogni nuova chiave privacy/GameDVR deve essere registrata e non duplicata.
- `ZT-PRV-01` e `ZT-GDV-01` devono rispettare l'ownership definita; le sovrapposizioni sono ammesse solo se documentate.
- `TH-BEN-01` e `TH-PRV-01`/`TH-GDV-01` sono di TweakHub e non vanno implementati in questo repository.

## Evoluzioni rinviate — non autorizzate all'implementazione

Le seguenti attività non sono task approvati e non vanno implementate senza un nuovo ID e una nuova autorizzazione:

- Journal persistente avanzato, locking e recovery dopo interruzioni oltre al punto di estensione minimo di `ZT-RB-00`.
- Rimozione del pacchetto Xbox Game Bar in ZapTweaks.
- Modalità esperta VBS/HVCI in ZapTweaks.
- Nuovi profili privacy o GameDVR non presenti nel catalogo approvato.
- Import JSON USB in NeuroTune.Skill (`NT-USB-01`).
- Qualunque task P3 o esterno non elencato in questo documento.

## Scartati

- `ST-HT-01`: nessun task per documentare il rigetto di Hypertune.
- `X-DOC-01` come task separato: la matrice evidenze è un criterio di accettazione.
- Task per memory cleaner, FPS booster, tweak pseudoscientifici o progetti esterni non compatibili.

## Riferimenti operativi

- `HANDOFF.md`: stato corrente, WIP e regole di progetto.
- `lib/models/system_checks_tweaks.dart`: System Checks.
- `lib/core/tweak_manager.dart`: metodi legacy e gestione errori.
- `lib/models/privacy_bloatware_tweaks.dart`: privacy e GameBar.
- `lib/models/gaming_optimizations_tweaks.dart`: GameDVR/FSE e profili AMD.
- `lib/models/networking_tweaks.dart`, `ui_visuals_tweaks.dart`, `reference_tweaks.dart`: script e rollback.
- `lib/core/operations/registry_dword_operation.dart`: snapshot/evidence delle operazioni tipizzate.
- `lib/features/tweaks/application/tweak_controller.dart`: disponibilità, conflitti e stato UI.
