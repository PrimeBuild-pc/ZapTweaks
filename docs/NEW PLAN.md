# NEW PLAN — Specifica vincolante per ZapTweaks One App

**Stato:** approvato dal proprietario del progetto  
**Ambito:** progettazione e implementazione della nuova architettura ZapTweaks  
**Piattaforma iniziale:** Windows 11 x64, desktop gaming  
**Framework UI:** Flutter esistente  
**Lingue obbligatorie per tutte le nuove funzioni:** inglese e italiano

## 0. Autorità del documento

Questo file è la specifica vincolante per gli agenti e gli sviluppatori che implementano la nuova versione di ZapTweaks. In caso di conflitto con `docs/visione-zaptweaks-one-app.md`, con la UI attuale o con convenzioni legacy, prevale questo documento.

Gli agenti devono:

1. lavorare per fasi, senza una riscrittura totale in un solo passaggio;
2. conservare tutti i 346 ID correnti;
3. mantenere compilazione, test e comportamento raggiungibile alla fine di ogni fase;
4. non dichiarare implementata una funzione che non legge e verifica lo stato reale;
5. non sostituire un rollback esatto con un valore predefinito presunto;
6. non introdurre profili raccomandati prima della Fase 8;
7. non implementare game overlay, creazione/modifica ISO o registry cleaner nativo.

Nessuna fase autorizza automaticamente operazioni di flashing, bypass di sicurezza, disabilitazione di protezioni o esecuzione di codice remoto mutabile.

---

## 1. Obiettivo di prodotto

ZapTweaks deve diventare l’unica applicazione necessaria per inventariare, configurare, verificare e ripristinare un desktop Windows 11 da gaming. I tool studiati sono inventari funzionali e fallback, non modelli da copiare indiscriminatamente.

Principio centrale:

> Un solo pannello, operazioni leggibili, stato reale, nessuna magia irreversibile.

L’utente deve poter:

- usare l’app senza elevazione per consultare il sistema;
- capire cosa cambierà prima dell’applicazione;
- applicare un piano con una sola richiesta UAC;
- vedere l’esito verificato di ogni passaggio;
- riavviare quando necessario senza perdere il journal;
- ripristinare i valori catturati prima della modifica;
- continuare ad aprire i tool esterni originali da `Esperto → Tool esterni`.

---

## 2. Decisioni non negoziabili

### 2.1 Supporto

- Supporto iniziale: Windows 11 x64 Home e Pro ancora supportate da Microsoft.
- Enterprise ed Education: supporto quando le API e le policy coincidono; mostrare chiaramente limitazioni da dominio, MDM o criteri organizzativi.
- Windows 10 e ARM64: fuori dal primo rilascio stabile.
- Build non supportate: consentire inventario e report, ma bloccare operation non validate.
- Target primario: desktop gaming. I valori DC dei piani energetici sono mostrati solo quando una batteria è rilevata, ma devono essere preservati durante import/export e snapshot.

### 2.2 Distribuzione e rete

- Conservare installer e build portable.
- Inventario, tweak nativi, diagnostica, journal e rollback devono funzionare offline.
- Cataloghi online, download e aggiornamenti richiedono rete.
- Tool, driver, installer e power plan opzionali devono essere on-demand.
- Nessun payload opzionale pesante deve restare nel pacchetto principale.
- I file già scaricati possono essere riutilizzati da una cache gestibile dall’utente.

### 2.3 Funzioni escluse

- Nessun game overlay.
- Nessun servizio residente di monitoraggio.
- Nessun registry cleaner nativo.
- Nessuna creazione o modifica di ISO.
- Nessun flashing automatico di BIOS, VBIOS o firmware.
- Nessun driver pack o mirror non ufficiale come comportamento predefinito.
- Nessuna esecuzione standard del tipo `irm URL | iex` o equivalente.
- Nessun accesso ring-0 tramite WinRing0, driver noti vulnerabili o disattivazione della vulnerable driver blocklist.
- Nessuna scrittura diretta generalizzata a MSR, PCI configuration space o MMIO come tweak di produzione; un futuro caso eccezionale richiede specifica hardware pubblica, componente firmato, allowlist per modello e approvazione separata.
- Nessun profilo Gaming raccomandato prima della Fase 8.

### 2.4 Sicurezza

Nessun profilo o wizard deve disabilitare automaticamente Defender, firewall, UAC, SmartScreen, Secure Boot, VBS/HVCI, mitigazioni Spectre/Meltdown o vulnerable driver blocklist. Le operation che riducono tali protezioni appartengono a Esperto, richiedono un avviso specifico e non possono essere selezionate implicitamente. Nessuna operation può ridurre una protezione come prerequisito nascosto per caricare un driver o rendere applicabile un’altra operation.

---

## 3. Baseline corrente verificata

Il catalogo corrente contiene esattamente **346 descriptor con ID univoco**.

| Categoria corrente | Quantità |
|---|---:|
| Shortcuts | 29 |
| Gaming | 14 |
| Networking | 15 |
| Power & CPU | 16 |
| Graphics | 19 |
| Windows | 45 |
| System Checks | 17 |
| Services | 31 |
| Refresh & Recovery | 23 |
| Setup | 12 |
| Advanced | 23 |
| Privacy | 12 |
| Visuals | 14 |
| Tools | 76 |
| **Totale** | **346** |

### 3.1 Classificazione tecnica disgiunta

| Tipo | Quantità | Trattamento iniziale |
|---|---:|---|
| Toggle con stato | 125 | Adapter legacy, audit dello stato e migrazione a operation native |
| Azioni/script legacy non esterni | 97 | 95 script interattivi, un comando terminale e un preset legacy da scomporre |
| Collegamenti Windows | 29 | Launcher nativi senza elevazione |
| Ripristino AppX | 17 | Gestore AppX/App con ID conservato |
| Tool e integrazioni esterne | 78 | Registro tool on-demand permanente |
| **Totale** | **346** | Nessun ID perso |

Sono presenti 37 titoli marcati `Script Variant`. Ventitré sono candidati diretti ad alias canonici; quattordici richiedono una scomposizione semantica. Un alias può essere attivato solo dopo aver confrontato integralmente il comportamento dello script e della operation di destinazione.

### 3.2 Regola di conservazione

Ogni ID dell’Allegato A deve avere uno stato di migrazione esplicito:

- `native`: operation gestita dal nuovo motore;
- `alias`: ID storico che risolve a una operation canonica equivalente;
- `legacy`: comportamento corrente ancora raggiungibile durante la migrazione;
- `external`: tool o integrazione on-demand sempre disponibile;
- `shortcut`: collegamento a Windows o a una fonte ufficiale;
- `rejected`: automazione vietata, con ID conservato come documentazione del motivo.

Un elemento alias non deve generare una seconda card identica, ma deve rimanere risolvibile da ricerca, importazioni, journal storici e API interne.

---

## 4. Navigazione definitiva

La shell principale deve contenere nove destinazioni. Ogni funzione ha una sola destinazione canonica; ricerca globale e collegamenti contestuali possono raggiungerla da altre pagine. La ricerca deve indicizzare nomi, descrizioni, ID, categorie e raccolte dei tweak, tutte le app dello store, i tool esterni e le sezioni integrate; deve accettare frammenti e piccoli errori di digitazione e portare alla destinazione canonica.

### 4.1 Home

- stato generale della macchina;
- CPU, GPU, RAM, scheda madre, dischi, rete e monitor;
- sicurezza, Windows Update e stato driver;
- spazio libero e salute storage;
- modifiche recenti;
- operation in attesa di riavvio;
- differenze rispetto alla baseline;
- errori concreti che richiedono attenzione.

Home non deve mostrare punteggi artificiali di ottimizzazione o promesse di prestazioni.

### 4.2 Setup guidato

Il wizard è proposto una volta quando esistono segnali affidabili di installazione recente. Deve rimanere avviabile manualmente.

Ordine:

1. inventario;
2. baseline;
3. aggiornamenti Windows necessari;
4. controllo driver;
5. selezione applicazioni;
6. debloat selettivo;
7. privacy e interfaccia;
8. anteprima del piano;
9. applicazione;
10. verifica finale e report.

Il wizard non contiene preset Gaming nella prima implementazione. Compone esclusivamente un piano leggibile a partire dalle scelte esplicite dell’utente.

### 4.3 App

- catalogo winget e fonti ufficiali;
- applicazioni desktop e Store installate;
- installazione, aggiornamento e disinstallazione;
- AppX provisioned e per-user;
- ripristino delle 17 app Microsoft già catalogate;
- funzionalità opzionali Windows;
- applicazioni in avvio;
- runtime come Visual C++ e DirectX;
- debloat con dipendenze e anteprima;
- stato ed esito per singolo pacchetto.

Il catalogo normalizza i riferimenti di WinUtil e Winhance senza creare duplicati per la stessa identità winget/AppX.

### 4.4 Driver

- inventario PnP e Device Instance ID;
- dispositivi mancanti, disabilitati o in errore;
- distinzione tra driver Microsoft, OEM e vendor;
- gestione diretta da fonti ufficiali AMD, NVIDIA e Intel quando esiste un endpoint stabile;
- procedura assistita per motherboard e periferiche;
- selezione di pacchetti locali;
- verifica Authenticode, hash, versione e publisher;
- Driver Store, esportazione e rimozione controllata;
- blocco degli aggiornamenti driver tramite Windows Update, temporaneo con scadenza oppure persistente fino a ripristino esplicito dello snapshot;
- scadenza e promemoria della policy temporanea;
- verifica dopo installazione e riavvio.

Non assumere che il driver numericamente più recente sia il migliore. Se una fonte vendor non è interrogabile in modo stabile, aprire la pagina ufficiale e guidare l’utente senza scraping fragile.

### 4.5 Gaming & Prestazioni

- grafica e display;
- impostazioni Windows per singolo gioco;
- CPU e scheduling;
- piani energetici ed editor PowrProf;
- memoria e cache;
- storage;
- rete e adattatori;
- tab `TCP Optimizer` nativa, con inventario live, configurazione TCP tipizzata, QoS per applicazione, misure diagnostiche e ripristino;
- input e periferiche;
- Game Mode, HAGS, VRR e flip model;
- timer e latenza;
- diagnostica prestazionale contestuale.

Le descrizioni devono distinguere beneficio ipotetico, effetto documentato, costo energetico, rischio di instabilità e necessità di benchmark.

### 4.6 Windows

- privacy;
- Esplora file;
- Start e taskbar;
- tema e accessibilità;
- Windows Update;
- servizi live;
- attività pianificate;
- rete e condivisione;
- sicurezza;
- funzionalità opzionali;
- impostazioni di sistema;
- collegamenti agli strumenti nativi.

### 4.7 Diagnostica & Ripristino

- pulizia con anteprima di file e spazio;
- DISM e SFC con output e log;
- log CBS/DISM;
- eventi essenziali e Reliability Monitor;
- startup e processi;
- memoria e cache;
- storage e SMART quando disponibile;
- DPC/ISR/TimerDPC tramite sessione ETW on-demand;
- sensori hardware disponibili e VRAM per processo;
- snapshot e confronto;
- restore point;
- journal e rollback;
- reset, reinstallazione e recovery;
- report Markdown e JSON.

Le funzionalità di pulizia devono elencare gli elementi prima della rimozione. Non analizzare o cancellare chiavi di registro “inutilizzate”.

### 4.8 Esperto

- catalogo completo delle operation;
- BCD, timer e policy avanzate;
- operation che riducono la sicurezza;
- editor MSI/MSI-X e interrupt affinity;
- topologia e assegnazione processori;
- impostazioni energetiche nascoste;
- registro e policy effettive;
- shell amministrative;
- firmware e BIOS solo assistiti;
- Tool esterni.

La modalità Esperto è disabilitata di default e si abilita esplicitamente da Impostazioni. Disabilitarla nasconde i controlli, non annulla le modifiche già applicate.

### 4.9 Impostazioni

- lingua italiano/inglese;
- tema chiaro/scuro/sistema;
- aggiornamenti ZapTweaks;
- cache download;
- fonti, licenze e attribuzioni;
- conservazione snapshot e log;
- privacy ed esportazione dati;
- modalità Esperto.

### 4.10 Distribuzione canonica dei 346 ID

| Destinazione | ID correnti |
|---|---:|
| Home | 0 |
| Setup guidato | 10 |
| App | 32 |
| Driver | 10 |
| Gaming & Prestazioni | 70 |
| Windows | 86 |
| Diagnostica & Ripristino | 20 |
| Esperto | 118 |
| Impostazioni | 0 |
| **Totale** | **346** |

Home e Impostazioni sono infrastrutture applicative nuove. Il numero di nuove operation introdotte per la parità con i tool di riferimento non è incluso nei 346 ID legacy.

---

## 5. Copertura dei riferimenti funzionali

| Riferimento | Funzioni da assorbire | Regola sorgente |
|---|---|---|
| CTT WinUtil | app, AppX, tweak, fix, configurazione e launcher Windows | codice MIT riutilizzabile solo con attribuzione; preferire API documentate |
| Winhance | inventario software, optimize e customize | studio clean-room; non copiare codice o implementazioni per la licenza PolyForm Shield |
| Wintoys | app installate, servizi live, salute, cleanup, repair, startup e memoria | reimplementazione tramite API Windows |
| WTools | diagnostica, DPC, sensori, VRAM, cleanup, repair e tool amministrativi | niente overlay; registry cleaner escluso |
| PowerSettingsExplorer | inventario completo dei power setting, piani, import/export e valori nascosti | implementazione PowrProf, non parsing localizzato |
| PowerPlanSettingsEditor | confronto AC/DC, descrizioni, ricerca, modifica e gestione piani | sorgente MIT con attribuzione se riutilizzata |
| MSI Utility | supporto Line-Based/MSI/MSI-X, limite e priorità | validazione hardware obbligatoria |
| Interrupt Affinity Policy Tool | policy, maschera processori e riavvio dispositivo | snapshot esatto obbligatorio |
| GoInterruptPolicy | SetupAPI, CPU topology, MSI e affinity unificati | sorgente MIT con attribuzione se riutilizzata |
| WINSPAR Windows TCP Optimizer | stato TCP globale, configurazione manuale, QoS per applicazione, misura throughput e backup/ripristino | riferimento clean-room AGPL-3.0 alla revisione `6392524fcd51925ffe0e082a76facf5b3bb8f322`; nessuna copia o derivazione del codice dentro l’app MIT |
| Zenit Latency Suite, corpus locale fino a Engine v8.0 | inventario RSS/NDIS, dry run, read-back, restore point, analisi statica Ghidra e tracce Procmon | solo ricerca statica; licenza del codice applicativo non dichiarata, nessun riuso |

### 5.1 Tool esterni permanenti

`Esperto → Tool esterni` deve includere almeno:

- CTT WinUtil;
- Winhance;
- Wintoys;
- WTools;
- PowerSettingsExplorer;
- PowerPlanSettingsEditor;
- MSI Utility v3;
- Interrupt Affinity Policy Tool;
- GoInterruptPolicy;
- WINSPAR Windows TCP Optimizer;
- tutti i 78 tool/integrazioni già presenti nell’Allegato A.

Una sostituzione nativa non autorizza la rimozione del tool. La card può mostrare `Funzione nativa disponibile`, ma deve continuare a offrire download/apertura del riferimento originale.

### 5.2 Decisioni derivate dall’analisi statica di Zenit Engine v8.0

Il corpus locale analizzato il 10 settembre 2026 contiene 6.091 file e 3.840.378.607 byte. Rispetto alla copia precedente Engine 7.0, 5.578 file sono identici, 28 modificati, 485 aggiunti e 2 rimossi; l’aumento di 1.608.950.976 byte è quasi interamente composto da progetti e risultati Ghidra. Non è stato eseguito alcun file.

Adottare soltanto questi principi:

- distinguere capacità NDIS dichiarate dal driver e policy RSS del sistema operativo;
- identificare l’adapter tramite PnP Device Instance ID e Interface GUID, mai soltanto tramite nome visualizzato;
- eseguire lavori lunghi fuori dal thread UI, con avanzamento, timeout e chiusura deterministica;
- usare read-back e dry run, senza considerarli sostituti di snapshot e rollback;
- usare documentazione, analisi statica con hash/build e tracce runtime come gate di ricerca del catalogo;
- separare la prova che un componente legge un valore dalla prova che un valore è valido e dalla prova di un beneficio misurabile.

Non adottare:

- WinRing0, servizi kernel automatici o disattivazione della vulnerable driver blocklist;
- scritture dirette a MSR, PCIe, xHCI, NVMe MMIO o registri vendor senza una base hardware supportata;
- valori NDIS inventati, creazione di `Ndi\Params` per “sbloccare” capacità o fallback registry quando l’API RSS rifiuta un valore;
- preset RSS basati soltanto sul numero di core;
- disattivazione in blocco dei binding diversi da IPv4/IPv6, reset Winsock/IP o restart automatico dell’adapter;
- etichette “100% verificato” derivate da una stringa nel binario, da una singola traccia Procmon o dal solo read-back.

I risultati inclusi confermano, su una specifica build non generalizzabile, il consumo di `TcpAckFrequency`, `TcpDelAckTicks` e `FastSendDatagramThreshold`. Questo giustifica ricerca e test mirati, non valori raccomandati né nuovi preset. La mancata osservazione in una traccia non prova che un valore sia placebo.

---

## 6. Architettura del codice

Mantenere Flutter. Non riscrivere l’app in un altro framework.

Struttura obiettivo:

```text
lib/
  app/
    navigation/
    shell/
    settings/
  core/
    operations/
      definitions/
      registry/
      execution/
      compatibility/
    plans/
    inventory/
    storage/
    downloads/
    safety/
    localization/
    logging/
    platform/
  features/
    home/
    setup/
    apps/
    drivers/
    gaming/
    windows/
    diagnostics/
    expert/
  legacy/
    adapters/
    catalog/
windows/
  runner/
  zaptweaks_native/
  zaptweaks_helper/
test/
  catalog/
  operations/
  plans/
  migration/
  localization/
  security/
```

Non creare livelli vuoti o interfacce con una sola implementazione senza necessità. La separazione è richiesta quando esistono privilegi diversi, API native, persistenza o testabilità reale.

### 6.1 Flusso unico

```text
Flutter UI
  → Feature controller
  → Operation registry
  → Plan engine
  → Platform service o legacy adapter
  → Elevated helper quando necessario
  → verifica
  → journal e snapshot
```

`TweakCatalogService`, `TweakController`, `TweakManager` e `SystemTweak` non devono continuare a costituire un secondo motore parallelo. Durante la migrazione sono raggiunti esclusivamente tramite adapter; alla chiusura della Fase 7 non devono più eseguire operation native.

---

## 7. Contratto delle operation

### 7.1 Identità

Ogni definizione deve dichiarare:

- `id` stabile;
- `version` dello schema/comportamento;
- `legacyAliases`;
- `titleKey` e `descriptionKey`;
- dominio e destinazione canonica;
- scope: utente, macchina, dispositivo, app, driver o power plan;
- target parametrico quando l’oggetto è dinamico;
- fonte tecnica e riferimenti documentali;
- per le operation mutanti, `mechanismEvidence`, `valueEvidence` e `benefitEvidence` separati;
- build, versione e SHA-256 del binario quando l’evidenza deriva da analisi statica o runtime.

L’evidenza minima distingue `documented`, `runtimeObserved`, `staticConfirmed`, `inferred`, `unverified` e `rejected`. `runtimeObserved` dimostra soltanto che quel percorso è stato esercitato; `staticConfirmed` soltanto che lo specifico binario analizzato contiene un consumer plausibile. Nessuno dei due livelli dimostra da solo beneficio, sicurezza del valore o validità su altre build.

Gli ID esistenti non vengono rinominati. I nuovi ID usano forma `domain.resource.action` in minuscolo ASCII. Dispositivi, pacchetti e power setting non generano migliaia di definizioni: usano una definizione parametrica con target validato.

### 7.2 Compatibilità

Ogni operation deve esporre:

- build minima e massima validata quando necessaria;
- edizioni supportate;
- architettura;
- vendor CPU/GPU;
- requisito batteria;
- requisito servizio, componente, comando o API;
- support predicate eseguita prima di mostrare l’azione come applicabile.

Un’operation non applicabile resta visibile con spiegazione, salvo elementi hardware irrilevanti che possono essere filtrati. Non deve diventare applicabile tramite un semplice force flag generico.

### 7.3 Stato

Lo stato non è booleano. Il modello minimo è:

- `unknown`;
- `notApplicable`;
- `absent`;
- `configured` con valore tipizzato;
- `mixed`;
- `pendingRestart`;
- `drifted`;
- `error`.

`unknown` non equivale mai a `false`, `disabled` o `default`. Errori di lettura non devono mostrare un toggle spento.

### 7.4 Capacità obbligatorie

Ogni operation dichiara:

- `inspect`;
- `plan`;
- `captureSnapshot`;
- `apply`;
- `verify`;
- `rollback`;
- `dependencies`;
- `conflicts`;
- `risk`;
- `privilege`;
- `restartImpact`;
- `rollbackCapability`.

`rollbackCapability` assume uno dei valori:

- `exact`;
- `bestEffort`;
- `manual`;
- `none`.

App rimosse, driver sostituiti e file cancellati non possono essere dichiarati `exact` se il payload originale non è stato salvato. L’interfaccia deve mostrare il limite prima dell’applicazione.

### 7.5 Idempotenza

Applicare due volte la stessa operation allo stesso target non deve accumulare modifiche. `verify` deve leggere nuovamente il sistema; non può limitarsi all’exit code del comando.

---

## 8. Plan Engine

Anche un toggle semplice viene eseguito come piano di una sola operation.

### 8.1 Ciclo di vita

1. risolvere definition, target e parametri;
2. leggere lo stato;
3. verificare compatibilità;
4. risolvere dipendenze e conflitti;
5. costruire anteprima e impatto;
6. acquisire tutti gli snapshot prima della prima mutazione;
7. richiedere una sola elevazione per il piano;
8. applicare in ordine deterministico;
9. verificare ogni operation;
10. registrare esito e valore scritto;
11. persistere richieste di riavvio;
12. produrre report finale.

Il piano deve avere un ID, timestamp, utente, versione ZapTweaks, build Windows, stato e lista ordinata delle operation.

### 8.2 Fallimenti

- Mutazioni di sistema: fermarsi al primo fallimento non ignorabile e offrire rollback delle operation già verificate.
- Installazioni app indipendenti: continuare sulle altre app, registrando ogni errore.
- Dipendenze: non eseguire un nodo se il prerequisito è fallito.
- Cancellazione utente: consentita solo tra due operation, non durante una scrittura atomica.
- Crash: al riavvio mostrare il piano incompleto e lo stato verificato, senza assumere né successo né fallimento.

### 8.3 Dry run

Il dry run deve eseguire inspect, support check, risoluzione conflitti e anteprima. Non deve simulare falsamente output di verifica o promettere che una mutazione avrà successo.

---

## 9. Snapshot, journal e rollback

### 9.1 Snapshot tipizzati

Conservare il dato grezzo necessario:

- registro: esistenza, tipo e bytes del valore;
- servizi: start type, delayed auto-start, stato, account e dipendenze rilevanti;
- task: XML originale, enabled state e presenza;
- power: GUID piano, piano attivo, AC/DC, attributi e valore;
- dispositivi: Device Instance ID, driver identity e valori interrupt;
- app: provider, package ID, versione e fonte reinstallabile;
- driver: published name, INF, versione, firma e posizione dell’eventuale export;
- file: percorso, hash e backup quando il rollback è dichiarato esatto.

SQLite contiene metadati e valori piccoli. Backup binari e driver stanno in file protetti, referenziati dal database.

### 9.2 Rollback consapevole dei conflitti

Prima di ripristinare:

1. leggere lo stato attuale;
2. confrontarlo con il valore scritto da ZapTweaks;
3. se coincide, ripristinare lo snapshot;
4. se differisce, segnare conflitto;
5. chiedere consenso prima di sovrascrivere una modifica successiva;
6. se il valore era assente, rimuovere solo il valore creato da ZapTweaks;
7. non eliminare un’intera chiave se contiene dati non creati dall’app.

### 9.3 Restore point

Il restore point è best effort e non sostituisce snapshot o backup. Per operazioni ad alto rischio:

- tentare la creazione;
- mostrare l’esito;
- se fallisce, richiedere conferma aggiuntiva;
- non registrarlo come riuscito senza verifica.

---

## 10. Privilegi ed Elevated Helper

L’app principale resta non elevata. La consultazione non deve generare UAC.

L’helper elevato deve:

- essere un eseguibile first-party incluso e firmato insieme all’app;
- avviarsi solo per un piano approvato;
- usare IPC con nome casuale, nonce e ACL limitata all’utente chiamante e agli amministratori;
- accettare operation allowlisted e parametri tipizzati;
- rifiutare executable, script o path arbitrari inviati dalla UI;
- convalidare nuovamente target e compatibilità lato elevato;
- inviare eventi strutturati di progresso;
- terminare alla fine del piano o su timeout;
- non installarsi come servizio permanente.

Il codice legacy che richiede PowerShell viene isolato nell’adapter. Non ampliare l’attuale `ProcessRunner` come API pubblica per aggirare il contratto delle operation.

---

## 11. Integrazioni Windows

### 11.1 Registro

Usare accesso tipizzato. Conservare tipo e bytes. Gestire vista registro 32/64 bit esplicitamente. Non interpretare “valore mancante” come zero. Non cancellare chiavi padre condivise.

### 11.2 Servizi

Usare Service Control Manager. Mostrare stato live, start type e dipendenze. Le azioni start/stop/configure sono separate. Servizi critici o gestiti da policy non entrano in selezioni massive. I servizi per-user con suffisso dinamico devono essere risolti a runtime.

### 11.3 Attività pianificate

Usare Task Scheduler API o interfacce di sistema stabili. Snapshot dell’XML prima di modificare o disabilitare. Mostrare trigger, principal, ultima esecuzione e prossimo avvio.

### 11.4 App, winget e AppX

- Identità normalizzata per provider e package ID.
- Passare argomenti come lista, senza concatenazione shell.
- Mostrare source e publisher.
- AppX provisioned e per-user sono stati distinti.
- Prima del debloat mostrare dipendenze e capacità di ripristino.
- Non rimuovere Store, Xbox o framework condivisi come effetto collaterale nascosto.

### 11.5 Driver

Usare SetupAPI, Configuration Manager, DISM e `pnputil` dove appropriato. Non analizzare output localizzato quando esiste un’API. Prima dell’installazione verificare Authenticode e corrispondenza hardware ID. La sospensione temporanea degli aggiornamenti driver ha scadenza e promemoria; il blocco persistente richiede un’azione esplicita, conserva il valore precedente e rimane visibile fino al ripristino. Firmware e BIOS restano manuali.

### 11.6 Power plan

Usare PowrProf per enumerare piani, sottogruppi, setting, descrizioni, valori possibili e AC/DC. `powercfg` può essere usato per import/export `.pow` e funzioni prive di equivalente pratico, senza dipendere da etichette localizzate.

Funzioni obbligatorie:

- elenco e piano attivo;
- ricerca;
- confronto tra piani;
- modifica tipizzata;
- import, export, duplicazione, rinomina, attivazione ed eliminazione;
- setting nascosti visibili dentro ZapTweaks senza cambiare il registro;
- azione Esperto separata per esporli nel pannello Windows;
- backup prima di `restoredefaultschemes`;
- verifica del piano realmente attivo.

I 91 power plan attuali diventano on-demand soltanto se fonte, licenza e checksum sono documentati. In assenza di diritto di redistribuzione, mantenere metadato/import locale o collegamento alla fonte, non il payload.

### 11.7 MSI e interrupt affinity

Enumerare i dispositivi presenti con SetupAPI e risorse IRQ. Usare Device Instance ID come identità persistente; `\Device\00000xxx` è solo informazione diagnostica.

Gestire separatamente:

- supporto Line-Based/MSI/MSI-X;
- `MSISupported`;
- `MessageNumberLimit` e massimo dichiarato;
- `DevicePriority`;
- `DevicePolicy`;
- `AssignmentSetOverride`.

Regole:

- non offrire MSI se dispositivo o driver non lo dichiarano;
- non superare il limite hardware;
- distinguere valore assente da zero;
- supportare topologia SMT, P/E-core, NUMA, LLC/CCD e processor groups;
- se una maschera non è rappresentabile in sicurezza, bloccare invece di troncare;
- nessun bulk apply raccomandato;
- nessun riavvio live automatico di storage controller, GPU, USB critici o input attivo;
- verificare dopo device restart o reboot;
- rilevare drift dopo reinstallazione driver.

### 11.8 Rete e adapter

- Enumerare adapter, binding, proprietà NDIS e stato RSS tramite API/documentazione Windows e metadati realmente esposti dal driver.
- Trattare `Set-NetAdapterRss`/provider equivalente e proprietà avanzate `*RSS` come superfici correlate ma distinte.
- Per RSS acquisire e ripristinare la tupla completa: enabled, profile, base/max processor, processor count, queue count e processor array risultante.
- Validare processor groups, NUMA, SMT, P/E-core, limiti di coda e località della NIC; nessun preset fisso “N core → M code”.
- Se il provider rifiuta un valore, mostrare il fallimento: non creare capacità nel registro e non usare fallback nascosti.
- Modificare binding, MTU IPv4/IPv6 e power management soltanto come operation atomiche e visibili; mai disabilitare in blocco componenti non riconosciuti.
- Un probe MTU è diagnostica e non autorizza un valore persistente basato su fallback o provider presunto.
- Restart adapter e reboot sono impatti pianificati e confermati, non effetti collaterali automatici.
- Un reset Winsock/IP non è rollback esatto e resta una procedura manuale di ultima istanza, non un’ottimizzazione.

La tab `TCP Optimizer` deve essere una UI ZapTweaks nativa e bilingue nella stessa sezione di Power Settings Explorer, non un wrapper del binario WINSPAR. Deve:

- mostrare lo stato live delle impostazioni TCP globali e dei template supportati, distinguendole dalle proprietà per-adapter già gestite dal servizio RSS;
- esporre soltanto valori enumerati dalla build corrente per autotuning, euristiche di scaling, ECN, RSC, RSS globale e provider/algoritmo di congestione;
- offrire gestione esplicita delle policy QoS per applicazione con nome, percorso, DSCP e throttle validati, senza monitor residente o modifica automatica di processi non selezionati;
- usare operation tipizzate con preview, snapshot esatto di valore presente/assente, una sola UAC quando richiesta, read-back, verify, journal e rollback;
- offrire misure prima/dopo di throughput, latenza, jitter e perdita come diagnostica ripetibile, senza dichiarare automaticamente un valore “migliore” da una singola speed test;
- integrare backup e ripristino nel journal ZapTweaks, senza file plaintext posizionali né parsing dipendente dalla lingua;
- attribuire `powplowdevs/WINSPAR-Windows-TCP-Optimizer` e mantenere un link alla sorgente originale.

Sono vietati nella reimplementazione: copia del codice AGPL dentro ZapTweaks MIT, inclusione degli `.exe` o del file test da 40 MiB, comandi costruiti da input non validato, cancellazione dell’intero ramo QoS, `gpupdate /force` implicito, modifica della priorità dei processi, auto-tuning mutante senza snapshot tra i campioni e dipendenze obbligatorie da endpoint speed-test terzi. Il dettaglio di handoff è in `docs/TCP_OPTIMIZER_HANDOFF.md`.

### 11.9 Diagnostica, ETW e sensori

Le sessioni ETW sono avviate su richiesta e chiuse anche in caso di errore. DPC/ISR deve mostrare driver, conteggi, durata e intervallo di osservazione, senza convertire automaticamente un picco in una diagnosi certa.

Sensori e VRAM:

- preferire API Windows e contatori documentati;
- indicare fonte e indisponibilità;
- non inventare temperatura o fan speed quando il firmware non li espone;
- non installare un kernel driver soltanto per popolare la dashboard;
- interrompere polling quando la pagina non è visibile;
- nessun OSD o hook nei processi di gioco.

### 11.10 Pulizia e repair

- Scansione e anteprima prima della cancellazione.
- Mostrare categoria, percorso, dimensione e motivo.
- Separare temp/cache, component store, Store cache e cleanup driver.
- DISM e SFC mostrano output, exit code e percorso log.
- Non cancellare file bloccati forzatamente senza un flusso specifico.
- Registry cleaner escluso.

---

## 12. Download, aggiornamenti e supply chain

Ogni artefatto on-demand ha un manifest locale versionato con:

- ID;
- versione;
- URL HTTPS ufficiale;
- publisher atteso;
- SHA-256 quando il file è immutabile;
- requisito Authenticode;
- licenza e diritto di redistribuzione;
- argomenti di installazione ammessi;
- dimensione e data di verifica.

Se hash o firma non coincidono, bloccare. Un redirect finale fuori dai domini consentiti richiede una regola esplicita. Non scegliere automaticamente il primo `.exe` di una release.

L’updater ZapTweaks può installare automaticamente solo build firmate da un publisher atteso o validate tramite un manifest firmato. Finché non esiste una catena di firma affidabile, deve limitarsi ad aprire la release ufficiale.

Il catalogo remoto non può introdurre command line, script o operation nuove. Le definizioni eseguibili arrivano con una release firmata dell’app.

---

## 13. Persistenza

Usare SQLite per:

- journal;
- snapshot;
- piani ed esiti;
- mapping legacy;
- cache metadata;
- riavvii pendenti;
- baseline e confronti.

Requisiti:

- migrazioni schema versionate e testate;
- transazioni per piano e snapshot;
- scrittura crash-safe;
- esportazione JSON/Markdown;
- nessun segreto o product key nei log;
- ACL utente sui dati locali;
- retention configurabile senza cancellazione silenziosa di snapshot ancora necessari a un rollback.

La versione portable continua a usare una directory dati esplicita e documentata; non deve scrivere accidentalmente in cartelle protette accanto all’eseguibile.

---

## 14. UI, UX e localizzazione

- Usare Fluent UI coerente con Windows 11.
- Supportare tema chiaro, scuro e sistema.
- Preferire tabelle compatte per driver, servizi, app, dispositivi e power setting.
- Evitare grandi card decorative ripetute.
- Virtualizzare liste grandi.
- Non bloccare il thread UI durante inventario, scansioni o piani.
- Le attività lunghe mostrano avanzamento, timeout e stato finale; la cancellazione è disponibile soltanto nei confini sicuri dichiarati dall’operation e non termina brutalmente una mutazione in corso.
- Processi e sessioni figli vengono chiusi deterministicamente anche su errore o uscita dall’app.
- Tutte le azioni devono essere utilizzabili con tastiera.
- Focus, contrasto, tooltip e scaling devono funzionare almeno al 100%, 125%, 150% e 200%.
- Icone non sostituiscono etichette per azioni distruttive.
- Rischio, privilegi e riavvio sono visibili prima dell’applicazione.

Ogni nuova stringa utente deve avere inglese e italiano nello stesso cambiamento. La CI deve fallire se una chiave manca in una delle due lingue. Le altre lingue arrivano prima della release stabile, dopo che il testo funzionale è consolidato.

---

## 15. Profili e preset

Fino alla Fase 8:

- non creare nuovi preset raccomandati;
- non mostrare un pulsante “ottimizza tutto”;
- mantenere gli ID legacy dei preset esistenti solo per compatibilità;
- consentire piani manuali e trasparenti, non profili opachi.

La Fase 8 può introdurre un profilo `Gaming competitivo raccomandato` soltanto quando:

1. tutte le famiglie funzionali sono implementate;
2. non esistono script opachi non classificati;
3. ogni operation inclusa ha stato e rollback dichiarati;
4. esistono benchmark ripetibili o documentazione tecnica adeguata;
5. il profilo elenca gli operation ID e i valori;
6. il profilo non modifica protezioni di sicurezza;
7. le operation non dichiarate restano intatte;
8. hardware incompatibile viene escluso automaticamente.

---

## 16. Migrazione per fasi

### Fase 0 — Congelamento baseline

- creare il registro machine-readable dei 346 ID dall’Allegato A;
- testare unicità, conteggio, destinazione e disposition;
- impedire modifiche al catalogo legacy prive di mapping.

**Gate:** esattamente 346 ID mappati, zero mancanti e zero duplicati.

### Fase 1 — Nuova shell

- implementare la navigazione definitiva;
- [x] ricerca globale su sezioni, app, operation e tool, con frammenti e tolleranza ai piccoli errori;
- [x] modalità Esperto;
- [x] adapter legacy;
- [x] tutti i comportamenti attuali ancora raggiungibili.

**Gate:** nessuna regressione di accessibilità ai 346 ID e ai tool esterni.

### Fase 2 — Fondamenta

- operation contract;
- registry;
- Plan Engine;
- SQLite;
- snapshot e journal;
- helper elevato;
- rollback e reboot continuation.

**Gate:** una operation campione per registro, servizio, power e dispositivo attraversa inspect, plan, snapshot, apply, verify e rollback in un ambiente di test.

### Fase 3 — Setup e App

- wizard;
- winget;
- AppX;
- componenti opzionali;
- startup;
- debloat con preview;
- restore delle 17 app.

**Gate:** nessuna rimozione senza preview; stato per-user/provisioned distinto; reinstallabilità dichiarata correttamente.

### Fase 4 — Driver

- inventario;
- AMD/NVIDIA/Intel;
- [x] flussi assistiti e accessi rapidi Windows verificati, incluso Device Manager via MMC;
- [x] pacchetti locali;
- [x] Driver Store;
- [x] firma e verifica;
- [x] Windows Update driver temporaneo e persistente con ripristino esatto.

**Gate:** nessun pacchetto non verificato viene eseguito; policy temporanee hanno scadenza; esito verificato dopo reboot.

### Fase 5 — Gaming e hardware

- PowrProf;
- CPU, grafica, rete, input e storage;
- controllo RSS tipizzato e topology-aware, senza preset o fallback registry;
- [x] sostituzione MSI Utility v3 integrata con inventario live, stato corrente per-device da `Enum\\PCI`, Line/MSI/MSI-X, limite messaggi, `DevicePriority`, rollback e read-back per display, rete, media, host USB e audio HD;
- [x] affinity tool integrato con tutte le policy documentate 0–5, topologia nativa `GetSystemCpuSetInformation`, selettori group-0 per logical CPU, un thread per core fisico, P/E-core, NUMA e LLC/CCD, maschera esatta, stato corrente e rollback;
- [x] Power Settings Explorer integrato tramite PowrProf con tutti i setting enumerati, ricerca, gruppi, GUID, descrizioni, unità, valori possibili, limiti/incrementi live ed editing AC/DC tipizzato;
- [x] tab `TCP Optimizer` nativa ispirata clean-room a WINSPAR, con stato live, modifica tipizzata, QoS selettivo, diagnostica prima/dopo e rollback esatto secondo `docs/TCP_OPTIMIZER_HANDOFF.md`;
- [x] topologia CPU;
- verifica hardware-specifica.

**Gate:** nessun valore fuori range, nessuna maschera troncata, nessun setting incompatibile applicabile.

### Fase 6 — Windows e diagnostica

- servizi e task;
- privacy e shell;
- cleanup;
- DISM/SFC;
- [x] ETW/DPC con pagina nativa stile LatencyMon/WTools: durata selezionabile, rate, distribuzione per processore, moduli kernel quando esposti e provider, senza affermazioni causali;
- sensori e VRAM;
- recovery.

**Gate:** nessun monitor residente, cleanup sempre preceduto da scansione, sessioni ETW chiuse correttamente.

### Fase 7 — Chiusura legacy

- scomporre i 95 script interattivi non esterni;
- convalidare i 23 alias candidati;
- classificare le 14 procedure composite;
- spostare payload opzionali on-demand;
- ridurre gli attuali 535 MB di `resources/`;
- completare EN/IT;
- [x] mantenere tool esterni e indicizzarli nella ricerca globale;
- [x] aggiungere fonti ufficiali zoicware, benchmark, overclock e stress test senza bundling o esecuzione remota mutabile.

**Gate:** zero azioni non classificate, zero command path remoto mutabile, zero ID legacy irrisolti.

### Fase 8 — Profili

- raccogliere evidenze;
- definire benchmark;
- progettare il profilo competitivo;
- mostrare diff e operation ID;
- testare applicazione e annullamento senza toccare valori esterni al profilo.

**Gate:** approvazione separata del proprietario del progetto prima di rendere il profilo raccomandato.

---

## 17. Test e qualità

### 17.1 Test automatici obbligatori

- conteggio e unicità dei 346 ID;
- una destinazione e disposition per ID;
- alias senza cicli;
- localizzazione EN/IT completa;
- support predicate;
- metadati di evidenza completi e riferiti a build/hash quando necessario;
- divieto di promuovere a raccomandata un’operation priva di `benefitEvidence` adeguata;
- RSS fuori capacità rifiutato senza scritture o fallback;
- TCP Optimizer: valori non esposti rifiutati, output strutturato indipendente dalla lingua, QoS confinato alla policy selezionata e benchmark incapace di mutare senza snapshot/rollback;
- serializzazione snapshot senza perdita di tipo;
- rollback di valore esistente e valore assente;
- conflitto dopo modifica manuale;
- ordine del piano e dipendenze;
- ripresa dopo crash/reboot;
- allowlist helper e rifiuto parametri arbitrari;
- firma/hash dei fixture download;
- parsing indipendente dalla lingua quando non si usano API;
- nessun profilo include operation di sicurezza vietate.

### 17.2 Test Windows

Usare VM o macchine sacrificabili. Non eseguire test distruttivi sul computer dello sviluppatore.

Matrice minima:

- Windows 11 Home e Pro supportati;
- Intel e AMD CPU;
- almeno una CPU ibrida Intel;
- AMD, NVIDIA e Intel GPU quando disponibile;
- sistema con e senza batteria per i power plan;
- dispositivo MSI, MSI-X e Line-Based;
- tema chiaro/scuro e scaling multipli;
- sistema italiano e inglese.

### 17.3 Regola di successo

Un exit code zero non basta. Una operation è riuscita soltanto quando `verify` osserva lo stato atteso o registra esplicitamente `pendingRestart` con verifica differita.

---

## 18. Licenze e attribuzioni

- Mantenere `THIRD_PARTY_NOTICES.md` aggiornato.
- Registrare repository, revisione, licenza e parti riutilizzate.
- CTT WinUtil: MIT.
- PowerPlanSettingsEditor: MIT, revisione studiata `bc15755f981b7ed831126df29541922b4171501d`.
- GoInterruptPolicy: MIT, revisione studiata `f41fd1e325e1d3a386816c3586474e5f7bb63a25`.
- WINSPAR Windows TCP Optimizer: AGPL-3.0, revisione studiata `6392524fcd51925ffe0e082a76facf5b3bb8f322`; l’attribuzione da sola non rende il codice compatibile con la distribuzione MIT, quindi usare soltanto analisi clean-room del comportamento e API Windows documentate, senza copiare codice o asset.
- Winhance: solo inventario clean-room; non copiare codice.
- Zenit Latency Suite: solo ricerca statica; licenza del codice applicativo non dichiarata, quindi nessuna copia di sorgenti, database, profili, binari o descrizioni.
- Progetti senza licenza esplicita: nessun vendoring o copia.
- Binari terzi: verificare diritto di redistribuzione prima di includerli; in caso contrario usare download/apertura ufficiale.

---

## 19. Gate globali di accettazione

Una fase o pull request non è completa se:

- riduce il numero dei 346 ID senza una modifica esplicitamente approvata di questo documento;
- lascia un ID senza mapping;
- introduce due motori di esecuzione per la stessa operation;
- interpreta uno stato sconosciuto come disabilitato;
- usa rollback presunti;
- esegue un download non verificato;
- esegue codice remoto mutabile;
- carica un driver noto vulnerabile o riduce una protezione per rendere possibile un tweak;
- promuove a raccomandata una modifica senza evidenza separata di meccanismo, validità del valore e beneficio;
- dichiara successo senza verifica;
- rende applicabile una operation incompatibile;
- manca una stringa EN o IT;
- rimuove l’accesso a un tool esterno;
- introduce un overlay;
- introduce un servizio residente;
- automatizza registry cleaning o flashing;
- aggiunge un preset raccomandato prima della Fase 8.

---

## 20. Definition of Done finale

La trasformazione One App è completa quando:

1. i 346 ID legacy sono tutti risolti;
2. tutte le nuove famiglie inventariate dai tool sono native o hanno un fallback motivato;
3. nessuno script interattivo opaco è presentato come operation verificata;
4. tool e pacchetti opzionali sono on-demand;
5. l’app funziona offline per inventario e operation già disponibili;
6. snapshot, journal, verifica e rollback sono operativi;
7. i flussi driver, App, power, MSI/affinity, servizi e diagnostica superano i gate;
8. inglese e italiano sono completi;
9. non esistono overlay, registry cleaner nativo, ISO builder o flashing automatico;
10. il proprietario approva separatamente l’eventuale profilo Gaming competitivo.

---

# Allegato A — Matrice vincolante dei 346 ID legacy

La destinazione è canonica. La ricerca globale può mostrare collegamenti contestuali senza duplicare l’operation. `legacy → native` significa che il comportamento resta raggiungibile durante la migrazione ma deve essere sostituito entro la Fase 7.

| # | ID legacy | Titolo corrente | Destinazione | Disposition | Target o vincolo |
|---:|---|---|---|---|---|
| 1 | `shortcut_advanced_system_settings` | Advanced System Settings | Windows | `shortcut` | launcher Windows nativo |
| 2 | `shortcut_bluetooth` | Bluetooth and devices | Windows | `shortcut` | launcher Windows nativo |
| 3 | `shortcut_computer_management` | Computer Management | Diagnostica & Ripristino | `shortcut` | launcher Windows nativo |
| 4 | `shortcut_device_manager` | Device Manager | Driver | `shortcut` | launcher Windows nativo |
| 5 | `shortcut_directx_diagnostic` | DirectX Diagnostic | Diagnostica & Ripristino | `shortcut` | launcher Windows nativo |
| 6 | `shortcut_disk_management` | Disk Management | Diagnostica & Ripristino | `shortcut` | launcher Windows nativo |
| 7 | `shortcut_display` | Display | Windows | `shortcut` | launcher Windows nativo |
| 8 | `shortcut_environment_variables` | Environment Variables | Esperto | `shortcut` | launcher Windows nativo |
| 9 | `shortcut_event_viewer` | Event Viewer | Diagnostica & Ripristino | `shortcut` | launcher Windows nativo |
| 10 | `shortcut_game_mode` | Game Mode Settings | Gaming & Prestazioni | `shortcut` | launcher Windows nativo |
| 11 | `shortcut_graphics_settings` | Graphics Settings | Gaming & Prestazioni | `shortcut` | launcher Windows nativo |
| 12 | `shortcut_hosts_file` | Hosts File | Esperto | `shortcut` | launcher Windows nativo |
| 13 | `shortcut_installed_apps` | Installed Apps | App | `shortcut` | launcher Windows nativo |
| 14 | `shortcut_network` | Network | Windows | `shortcut` | launcher Windows nativo |
| 15 | `shortcut_optional_features` | Optional Features | Windows | `shortcut` | launcher Windows nativo |
| 16 | `shortcut_performance_monitor` | Performance Monitor | Diagnostica & Ripristino | `shortcut` | launcher Windows nativo |
| 17 | `shortcut_personalization` | Personalization | Windows | `shortcut` | launcher Windows nativo |
| 18 | `shortcut_power_battery` | Power and battery | Gaming & Prestazioni | `shortcut` | launcher Windows nativo |
| 19 | `shortcut_privacy_security` | Privacy and security | Windows | `shortcut` | launcher Windows nativo |
| 20 | `shortcut_registry_editor` | Registry Editor | Esperto | `shortcut` | launcher Windows nativo |
| 21 | `shortcut_reliability_history` | Reliability History | Diagnostica & Ripristino | `shortcut` | launcher Windows nativo |
| 22 | `shortcut_resource_monitor` | Resource Monitor | Diagnostica & Ripristino | `shortcut` | launcher Windows nativo |
| 23 | `shortcut_services` | Services | Windows | `shortcut` | launcher Windows nativo |
| 24 | `shortcut_sound` | Sound | Windows | `shortcut` | launcher Windows nativo |
| 25 | `shortcut_startup_folder` | Startup Folder | Windows | `shortcut` | launcher Windows nativo |
| 26 | `shortcut_system_configuration` | System Configuration | Esperto | `shortcut` | launcher Windows nativo |
| 27 | `shortcut_task_scheduler` | Task Scheduler | Esperto | `shortcut` | launcher Windows nativo |
| 28 | `shortcut_windows_features` | Windows Features | Windows | `shortcut` | launcher Windows nativo |
| 29 | `shortcut_windows_update` | Windows Update | Windows | `shortcut` | launcher Windows nativo |
| 30 | `cpu_amd_optimizations` | AMD Ryzen Optimizations | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 31 | `cpu_unparking` | CPU Core Unparking | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 32 | `cpu_power_management` | CPU Power Management | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 33 | `game_mode` | Game Mode On | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 34 | `cpu_intel_optimizations` | Intel CPU Optimizations | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 35 | `ram_optimizations` | RAM Optimizations | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 36 | `storage_optimizations` | Storage Optimizations | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 37 | `timer_latency` | Timer and Latency | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 38 | `gaming_mpo_off` | Disable Multiplane Overlay (MPO) | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 39 | `gaming_extended_gpu_timeout` | Extended GPU Timeout | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 40 | `gaming_legacy_flip_fse` | Fullscreen Exclusive Legacy Flip | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 41 | `gaming_composed_flip_immediate_mode` | Hardware Composed Independent Flip | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 42 | `gaming_windowed_optimizations_on` | Optimizations for Windowed Games On | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 43 | `gaming_variable_refresh_rate_on` | Variable Refresh Rate On | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 44 | `network_ecn_disabled` | Disable ECN | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 45 | `network_timestamps_disabled` | Disable TCP Timestamps | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 46 | `network_rss_enabled` | Enable RSS | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 47 | `network_optimizations` | Network Optimizations | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 48 | `network_adapter_power_savings_wake_off` | Adapter Power Savings and Wake Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 49 | `network_delivery_optimization_off` | Delivery Optimization P2P Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 50 | `device_power_savings_off` | Device Power Saving Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 51 | `network_fast_udp_datagram_send` | Fast UDP Datagram Send | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 52 | `network_ipv4_only` | IPv4 Only Bindings | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 53 | `network_llmnr_off` | LLMNR Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 54 | `network_low_latency_bandwidth_profile` | Low-Latency Network Profile | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 55 | `network_mmagent_features_off` | MMAgent Features Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 56 | `network_throttling_index_off` | Network Throttling Index Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 57 | `network_prefer_ipv4` | Prefer IPv4 over IPv6 | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 58 | `network_itr_interactive_config` | NIC ITR Interactive Config | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 59 | `power_amd_preferred_cores` | AMD Preferred Cores | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 60 | `power_cpu_core_parking_off` | CPU Core Parking Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 61 | `power_disable_cstates` | Disable CPU C-States | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 62 | `power_cpu_idle_demote_promote` | Disable CPU Idle Demote/Promote | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 63 | `power_disable_dynamic_tick` | Disable Dynamic Tick | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 64 | `power_fast_startup_hibernate_off` | Fast Startup and Hibernate Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 65 | `power_global_timer_resolution` | Global Timer Resolution Requests | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 66 | `power_hardware_pstates_intel` | Intel Hardware P-States (HWP) | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 67 | `power_max_processor_state` | Maximum Processor State (100%) | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 68 | `power_throttling_off` | Power Throttling Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 69 | `power_processor_boost_mode` | Processor Performance Boost Mode | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 70 | `power_processor_time_check_interval` | Processor Time Check Interval (5ms) | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 71 | `power_system_responsiveness_registry` | System Responsiveness (10) | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 72 | `power_tsc_sync_policy` | TSC Sync Policy (Enhanced) | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 73 | `power_ultimate_performance_plan` | Ultimate Performance Power Plan | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 74 | `power_win32_priority_separation` | Win32 Priority Separation (Gaming) | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 75 | `gpu_amd_optimizations` | AMD GPU ULPS Troubleshooting | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 76 | `gpu_intel_optimizations` | Intel GPU Optimizations | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 77 | `gpu_nvidia_optimizations` | NVIDIA Optimizations | Gaming & Prestazioni | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 78 | `gaming_amd_gpu_extreme_profile` | AMD GPU Extreme Profile | Gaming & Prestazioni | `legacy` | compatibilità soltanto; nuovo sistema di profili rinviato alla Fase 8 |
| 79 | `gaming_amd_gpu_safe_profile` | AMD GPU Safe Profile | Gaming & Prestazioni | `legacy` | compatibilità soltanto; nuovo sistema di profili rinviato alla Fase 8 |
| 80 | `gaming_amd_ulps_off` | AMD ULPS Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 81 | `graphics_amd_settings` | AMD Settings | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 82 | `graphics_directx` | DirectX Runtime | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 83 | `graphics_driver_clean` | Driver Clean | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 84 | `graphics_driver_install_debloat_settings` | Driver Install Debloat & Settings | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 85 | `graphics_driver_install_latest` | Driver Install Latest | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 86 | `graphics_hags_windowed` | HAGS Windowed | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 87 | `graphics_hdcp` | HDCP | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 88 | `graphics_intel_settings` | Intel Settings | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 89 | `graphics_msi_mode_script` | MSI Mode (Script Variant) | Esperto | `alias` | device.interrupt.editor; unire solo dopo verifica di equivalenza semantica |
| 90 | `graphics_nvidia_settings` | NVIDIA Settings | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 91 | `graphics_p0_state` | P0 State | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 92 | `graphics_resolution_refresh_rate` | Resolution Refresh Rate | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 93 | `graphics_cpp_runtime` | Visual C++ All-in-One Runtimes | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 94 | `system_responsiveness` | System Responsiveness | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 95 | `windows_update` | Windows Update Behavior | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 96 | `windows_auto_reboot_after_bsod_off` | Auto-reboot After BSOD Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 97 | `toggle_automatic_driver_updates_off` | Automatic Driver Updates Off | Driver | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 98 | `windows_automatic_maintenance_off` | Automatic Maintenance Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 99 | `windows_ntfs_last_access_updates_off` | NTFS Last-Access Updates Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 100 | `toggle_scheduled_defrag_off` | Scheduled Defrag / TRIM Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 101 | `toggle_storage_sense_off` | Storage Sense Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 102 | `windows_context_menu_script` | Context Menu (Script Variant) | Windows | `alias` | ui_context_menu_clean; unire solo dopo verifica di equivalenza semantica |
| 103 | `windows_control_panel_settings_script` | Control Panel Settings (Script Variant) | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 104 | `windows_notepad_settings` | Notepad Settings | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 105 | `windows_scaling` | Scaling | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 106 | `windows_signout_lockscreen_wallpaper_black` | Signout Lockscreen Wallpaper Black | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 107 | `windows_start_menu_layout_script` | Start Menu Layout (Script Variant) | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 108 | `windows_start_menu_shortcuts_script` | Start Menu Shortcuts (Script Variant) | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 109 | `windows_start_menu_taskbar_script` | Start Menu Taskbar (Script Variant) | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 110 | `windows_theme_black_script` | Theme Black (Script Variant) | Windows | `alias` | ui_dark_theme; unire solo dopo verifica di equivalenza semantica |
| 111 | `windows_user_account_pictures_black` | User Account Pictures Black | Windows | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 112 | `windows_widgets_script` | Widgets (Script Variant) | Windows | `alias` | privacy_widgets; unire solo dopo verifica di equivalenza semantica |
| 113 | `windows_device_manager_power_savings_wake` | Device Manager Power Savings & Wake | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 114 | `windows_loudness_eq` | Loudness EQ | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 115 | `windows_nvme_faster_driver` | NVME Faster Driver | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 116 | `windows_network_adapter_power_savings_script` | Network Adapter Power Savings & Wake (Script Variant) | Gaming & Prestazioni | `alias` | network_adapter_power_savings_wake_off; unire solo dopo verifica di equivalenza semantica |
| 117 | `windows_network_ipv4_only_script` | Network IPv4 Only (Script Variant) | Gaming & Prestazioni | `alias` | network_ipv4_only; unire solo dopo verifica di equivalenza semantica |
| 118 | `windows_pointer_precision_script` | Pointer Precision (Script Variant) | Gaming & Prestazioni | `alias` | ui_pointer_precision_off; unire solo dopo verifica di equivalenza semantica |
| 119 | `windows_sound` | Sound | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 120 | `windows_write_cache_buffer_flushing` | Write Cache Buffer Flushing | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 121 | `windows_core_isolation_script` | Core Isolation (Script Variant) | Esperto | `alias` | checks_core_isolation_off; unire solo dopo verifica di equivalenza semantica |
| 122 | `windows_defender_optimize` | Defender Optimize | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 123 | `windows_gamebar_script` | Gamebar (Script Variant) | Gaming & Prestazioni | `alias` | privacy_gamebar; unire solo dopo verifica di equivalenza semantica |
| 124 | `windows_gamemode` | Gamemode | Gaming & Prestazioni | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 125 | `windows_power_plan_script` | Power Plan (Script Variant) | Gaming & Prestazioni | `alias` | power.plan.editor; unire solo dopo verifica di equivalenza semantica |
| 126 | `windows_restore_point` | Restore Point | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 127 | `windows_timer_resolution_script` | Timer Resolution (Script Variant) | Gaming & Prestazioni | `alias` | power_global_timer_resolution; unire solo dopo verifica di equivalenza semantica |
| 128 | `windows_uac_script` | UAC (Script Variant) | Esperto | `alias` | checks_uac_off; unire solo dopo verifica di equivalenza semantica |
| 129 | `windows_autoruns_startup_tasks_apps_check` | Autoruns Startup Tasks & Apps Check | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 130 | `windows_bloatware_script` | Bloatware (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 131 | `windows_bloatware_legacy_apps_check_script` | Bloatware Legacy Apps Check (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 132 | `windows_bloatware_legacy_features_check_script` | Bloatware Legacy Features Check (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 133 | `windows_bloatware_taskmgr_check_script` | Bloatware TaskMgr Check (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 134 | `windows_bloatware_uwp_apps_check_script` | Bloatware UWP Apps Check (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 135 | `windows_bloatware_uwp_features_check_script` | Bloatware UWP Features Check (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 136 | `windows_cleanup` | Cleanup | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 137 | `windows_copilot_script` | Copilot (Script Variant) | Windows | `alias` | privacy_copilot; unire solo dopo verifica di equivalenza semantica |
| 138 | `windows_edge_webview_script` | Edge & WebView (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 139 | `checks_core_isolation_off` | Core Isolation Memory Integrity Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 140 | `checks_dep_off` | Data Execution Prevention Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 141 | `checks_firewall_off` | Firewall Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 142 | `checks_memory_compression_off` | Memory Compression Off | Gaming & Prestazioni | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 143 | `checks_smart_screen_off` | SmartScreen Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 144 | `checks_spectre_meltdown_off` | Spectre/Meltdown Mitigations Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 145 | `checks_uac_off` | UAC Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 146 | `checks_vbs_off` | Virtualization-Based Security Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 147 | `checks_vulnerable_driver_blocklist_off` | Vulnerable Driver Blocklist Off | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 148 | `check_bios_settings` | BIOS Settings Guide | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 149 | `check_bios_update` | BIOS Update Search | Diagnostica & Ripristino | `shortcut` | fonte ufficiale del produttore |
| 150 | `check_cpu_test` | CPU Test | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 151 | `check_gpu_check` | GPU Check | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 152 | `check_gpu_test` | GPU Test | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 153 | `check_ram_check` | RAM Check | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 154 | `check_ram_test` | RAM Test | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 155 | `check_space_check` | Space Check | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 156 | `service_diagtrack_off` | Connected User Experiences and Telemetry Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 157 | `service_diagsvc_off` | Diagnostic Execution Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 158 | `service_inventorysvc_off` | Inventory and Compatibility Appraisal Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 159 | `service_pcasvc_off` | Program Compatibility Assistant Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 160 | `service_troubleshootingsvc_off` | Recommended Troubleshooting Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 161 | `service_retaildemo_off` | Retail Demo Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 162 | `service_svsvc_off` | Spot Verifier Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 163 | `service_dmwappushservice_off` | WAP Push Message Routing Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 164 | `service_wersvc_off` | Windows Error Reporting Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 165 | `service_wecsvc_off` | Windows Event Collector Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 166 | `service_wisvc_off` | Windows Insider Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 167 | `service_devquerybroker_off` | DevQuery Background Discovery Broker Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 168 | `service_mapsbroker_off` | Downloaded Maps Manager Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 169 | `service_remoteregistry_off` | Remote Registry Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 170 | `service_remoteaccess_off` | Routing and Remote Access Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 171 | `service_lmhosts_off` | TCP/IP NetBIOS Helper Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 172 | `service_wmpnetworksvc_off` | Windows Media Player Network Sharing Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 173 | `service_efs_off` | Encrypting File System Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 174 | `service_semgrsvc_off` | Payments and NFC/SE Manager Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 175 | `service_scdeviceenum_off` | Smart Card Device Enumeration Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 176 | `service_scardsvr_off` | Smart Card Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 177 | `service_pimindexmaintenancesvc_off` | Contact Data Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 178 | `service_trkwks_off` | Distributed Link Tracking Client Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 179 | `service_wpcmonsvc_off` | Parental Controls Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 180 | `toggle_printing_off` | Printing Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 181 | `service_shpamsvc_off` | Shared PC Account Manager Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 182 | `service_messagingservice_off` | Text Messaging Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 183 | `service_wpnservice_off` | Windows Push Notifications System Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 184 | `service_xblauthmanager_off` | Xbox Live Auth Manager Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 185 | `service_xblgamesave_off` | Xbox Live Game Save Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 186 | `service_xboxnetapisvc_off` | Xbox Live Networking Service Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 187 | `refresh_account_local` | Account Local | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 188 | `refresh_autounattend` | Autounattend | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 189 | `refresh_factory_reset` | Factory Reset | Diagnostica & Ripristino | `shortcut` | Recovery di Windows |
| 190 | `refresh_reinstall` | Reinstall | Diagnostica & Ripristino | `shortcut` | Recovery di Windows |
| 191 | `refresh_to_bios` | To BIOS | Diagnostica & Ripristino | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 192 | `refresh_updates_drivers_block` | Updates Drivers Block | Driver | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 193 | `restore_clipchamp_clipchamp` | Restore Clipchamp | App | `native` | gestore AppX/App; conservare questo ID |
| 194 | `restore_microsoft_windowsalarms` | Restore Clock | App | `native` | gestore AppX/App; conservare questo ID |
| 195 | `restore_microsoft_devhome` | Restore Dev Home | App | `native` | gestore AppX/App; conservare questo ID |
| 196 | `restore_microsoft_windowsfeedbackhub` | Restore Feedback Hub | App | `native` | gestore AppX/App; conservare questo ID |
| 197 | `restore_microsoft_family` | Restore Microsoft Family | App | `native` | gestore AppX/App; conservare questo ID |
| 198 | `restore_microsoft_windowsstore` | Restore Microsoft Store | App | `native` | gestore AppX/App; conservare questo ID |
| 199 | `restore_microsoft_todos` | Restore Microsoft To Do | App | `native` | gestore AppX/App; conservare questo ID |
| 200 | `restore_microsoft_microsoftofficehub` | Restore Office Hub | App | `native` | gestore AppX/App; conservare questo ID |
| 201 | `restore_microsoft_onedrive` | Restore OneDrive | App | `native` | gestore AppX/App; conservare questo ID |
| 202 | `restore_microsoft_outlookforwindows` | Restore Outlook (new) | App | `native` | gestore AppX/App; conservare questo ID |
| 203 | `restore_microsoft_yourphone` | Restore Phone Link | App | `native` | gestore AppX/App; conservare questo ID |
| 204 | `restore_microsoft_powerautomatedesktop` | Restore Power Automate | App | `native` | gestore AppX/App; conservare questo ID |
| 205 | `restore_microsoft_quickassist` | Restore Quick Assist | App | `native` | gestore AppX/App; conservare questo ID |
| 206 | `restore_microsoft_stickynotes` | Restore Sticky Notes | App | `native` | gestore AppX/App; conservare questo ID |
| 207 | `restore_microsoft_gamingapp` | Restore Xbox App | App | `native` | gestore AppX/App; conservare questo ID |
| 208 | `restore_microsoft_xboxgamingoverlay` | Restore Xbox Game Bar | App | `native` | gestore AppX/App; conservare questo ID |
| 209 | `restore_microsoft_xboxidentityprovider` | Restore Xbox Identity Provider | App | `native` | gestore AppX/App; conservare questo ID |
| 210 | `setup_activation_script` | Activation (Script Variant) | Setup guidato | `shortcut` | Impostazioni di attivazione Windows |
| 211 | `setup_background_apps_script` | Background Apps (Script Variant) | Setup guidato | `alias` | ui_background_apps_off; unire solo dopo verifica di equivalenza semantica |
| 212 | `setup_bitlocker` | BitLocker | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 213 | `setup_convert_home_to_pro` | Convert Home To Pro | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 214 | `setup_date_language_region_time` | Date Language Region Time | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 215 | `setup_edge_settings_script` | Edge Settings (Script Variant) | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 216 | `setup_keys` | Keys | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 217 | `setup_memory_compression_script` | Memory Compression (Script Variant) | Gaming & Prestazioni | `alias` | checks_memory_compression_off; unire solo dopo verifica di equivalenza semantica |
| 218 | `setup_startup_apps_7` | Startup Apps (7) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 219 | `setup_startup_apps_8` | Startup Apps (8) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 220 | `setup_store_settings_script` | Store Settings (Script Variant) | App | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 221 | `setup_updates_pause` | Updates Pause | Setup guidato | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 222 | `bcd_optimizations` | Advanced Boot Optimizations | Esperto | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 223 | `services_disable` | Diagnostics Services | Esperto | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 224 | `advanced_core_1_thread_1` | Core 1 Thread 1 | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 225 | `advanced_dep_script` | Data Execution Prevention (Script Variant) | Esperto | `alias` | checks_dep_off; unire solo dopo verifica di equivalenza semantica |
| 226 | `advanced_defender` | Defender | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 227 | `advanced_driver_whql_secure_boot_bypass` | Driver WHQL Secure Boot Bypass | Esperto | `rejected` | documentare il rischio; non automatizzare il bypass di WHQL o Secure Boot |
| 228 | `advanced_file_download_security_warning` | File Download Security Warning | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 229 | `advanced_firewall_script` | Firewall (Script Variant) | Esperto | `alias` | checks_firewall_off; unire solo dopo verifica di equivalenza semantica |
| 230 | `advanced_hardware_composed_flip_script` | Hardware Composed Independent Flip (Script Variant) | Esperto | `alias` | gaming_composed_flip_immediate_mode; unire solo dopo verifica di equivalenza semantica |
| 231 | `advanced_hardware_legacy_flip_script` | Hardware Legacy Flip (Script Variant) | Esperto | `alias` | gaming_legacy_flip_fse; unire solo dopo verifica di equivalenza semantica |
| 232 | `advanced_keyboard_shortcuts` | Keyboard Shortcuts | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 233 | `advanced_mmagent_features_script` | MMAgent Features (Script Variant) | Esperto | `alias` | network_mmagent_features_off; unire solo dopo verifica di equivalenza semantica |
| 234 | `advanced_mpo_script` | MPO (Script Variant) | Esperto | `alias` | gaming_mpo_off; unire solo dopo verifica di equivalenza semantica |
| 235 | `advanced_priority` | Priority | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 236 | `advanced_rebar_force` | ReBar Force | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 237 | `advanced_smt_ht` | SMT HT | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 238 | `advanced_services` | Services | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 239 | `advanced_spectre_meltdown_script` | Spectre Meltdown (Script Variant) | Esperto | `alias` | checks_spectre_meltdown_off; unire solo dopo verifica di equivalenza semantica |
| 240 | `advanced_start_search_shell_mobsync` | Start Search Shell Mobsync | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 241 | `advanced_ulps_script` | ULPS (Script Variant) | Esperto | `alias` | gaming_amd_ulps_off; unire solo dopo verifica di equivalenza semantica |
| 242 | `tool_amdvbflash_download` | AMDVBFlash Download | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 243 | `tool_nvidia_nvflash_download` | NVIDIA NVFlash Download | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 244 | `tool_scewin_gui_releases` | SCEWIN-GUI Releases | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 245 | `telemetry_disable` | Disable Telemetry | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 246 | `privacy_tracking` | Privacy and Tracking | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 247 | `toggle_activity_history_off` | Activity History Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 248 | `privacy_consumer_content` | Consumer Content and Auto-App Suggestions | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 249 | `privacy_copilot` | Copilot Disable | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 250 | `privacy_gamebar` | Game Bar and Capture Overlay | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 251 | `toggle_location_off` | Location Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 252 | `privacy_online_search_suggestions` | Online Search Suggestions Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 253 | `privacy_powershell_telemetry` | PowerShell 7 Telemetry Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 254 | `privacy_widgets` | Widgets and News Feed | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 255 | `privacy_safe_debloat` | Safe Debloat Preset | App | `legacy` | compatibilità soltanto; nuovo sistema di profili rinviato alla Fase 8 |
| 256 | `tool_winsux_debloat` | WinSux by Fr33hty | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 257 | `visual_effects` | Disable Visual Effects | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 258 | `explorer_optimizations` | Explorer Optimizations | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 259 | `notifications_minimal` | Minimal Notifications | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 260 | `ui_optimizations` | UI Optimizations | Windows | `legacy` | scomporre il toggle composito in operation atomiche; conservare l’ID come ricetta di compatibilità |
| 261 | `ui_background_apps_off` | Background Apps Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 262 | `toggle_center_taskbar_icons` | Center Taskbar Icons | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 263 | `ui_context_menu_clean` | Context Menu Clean | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 264 | `ui_folder_discovery_off` | Folder Type Discovery Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 265 | `ui_hide_explorer_gallery` | Hide File Explorer Gallery | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 266 | `ui_pointer_precision_off` | Pointer Precision Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 267 | `ui_start_taskbar_clean` | Start Menu and Taskbar Clean | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 268 | `ui_sticky_keys_shortcut_off` | Sticky Keys Shortcut Off | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 269 | `ui_taskbar_end_task` | Taskbar End Task | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 270 | `ui_dark_theme` | Theme Black | Windows | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 271 | `hardware_background_polling_rate_cap` | Background Polling Rate Cap | Esperto | `native` | migrare con lettura, snapshot, verifica e rollback esatto; conservare l’ID |
| 272 | `tool_beyond_performance_device_tweaker_discord` | Beyond Performance Device Tweaker | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 273 | `tool_marius_cpudirect_script` | CPU Direct USB Port Check (Script) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 274 | `tool_marius_cpudirect_web` | CPU Direct USB Port Check (Web) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 275 | `hardware_controller_overclock_script` | Controller Overclock | Esperto | `legacy → native` | adattare subito, poi sostituire lo script con operation native o procedura assistita verificabile |
| 276 | `tool_marius_deeplog_script` | DeepLog Input Recorder (Script) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 277 | `tool_marius_deeplog_web` | DeepLog Input Recorder (Web) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 278 | `tool_marius_deeppoll_script` | DeepPoll USB Polling Analyzer (Script) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 279 | `tool_marius_deeppoll_web` | DeepPoll USB Polling Analyzer (Web) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 280 | `tool_device_tweaker_script` | Device Tweaker (LLG x LLC) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 281 | `tool_interrupt_affinity_policy` | Interrupt Affinity Policy Tool | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 282 | `tool_msi_util_folder` | MSI Utility v3 | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 283 | `tool_marius_heier_tools_hub` | Marius Heier Tools Hub | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 284 | `tool_mouse_flat_curve` | Mouse Flat Curve | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 285 | `tool_mouse_movement_recorder` | Mouse Movement Recorder | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 286 | `tool_polling_rate_tester_app` | Polling Rate Tester App | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 287 | `tool_controller_polling` | Polling Tool | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 288 | `tool_marius_step_count_noise_web` | Step Count vs Noise Joystick Demo | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 289 | `tool_marius_usb_hid_analyzer_web` | USB HID Polling Analyzer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 290 | `tool_hidusbf_folder` | hidusbf | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 291 | `tool_autoruns_folder` | Autoruns | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 292 | `tool_fix_tools_battery_report` | Battery Report | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 293 | `tool_cpuz_folder` | CPU-Z | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 294 | `tool_gpuz` | GPU-Z | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 295 | `tool_gaming_net_diagnostic` | Gaming Network Diagnostic | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 296 | `tool_hwinfo_folder` | HWiNFO | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 297 | `tool_rammap_folder` | RAMMap | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 298 | `tool_marius_rig_script` | Rig Profiles Hardware Report (Script) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 299 | `tool_marius_rig_web` | Rig Profiles Hardware Report (Web) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 300 | `tool_star_ethernet_analyzer_folder` | Star Ethernet Analyzer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 301 | `tool_star_ethernet_analyzer_script` | Star Ethernet Analyzer Script | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 302 | `tool_star_ethernet_analyzer_video` | Star Ethernet Analyzer Video Guide | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 303 | `tool_cru_folder` | CRU | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 304 | `installers_cru_sre` | CRU SRE Script Installer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 305 | `tool_nvidia_profile_inspector_download` | Download NVIDIA Profile Inspector | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 306 | `tool_gpu_dword_manager` | GPU DWORD Manager | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 307 | `tool_msi_afterburner_setup` | MSI Afterburner Installer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 308 | `installers_msi_afterburner` | MSI Afterburner Script Installer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 309 | `tool_more_clock_tool` | More Clock Tool | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 310 | `installers_more_clock_tool` | More Clock Tool Script Installer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 311 | `tool_more_power_tool_setup` | MorePowerTool Installer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 312 | `tool_nvidia_profile_inspector_folder` | NVIDIA Profile Inspector | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 313 | `tool_nvidia_profile_inspector_nip_profile` | NVIDIA Profile Inspector Profiles (.nip) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 314 | `tool_radeon_tuner_folder` | Radeon Tuner | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 315 | `tool_wtools_setup` | WTools 1.0.9.3 Installer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 316 | `tool_wtools_official_page` | WTools Official Page | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 317 | `tool_rtl_utility` | RTL Utility | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 318 | `tool_fix_tools_reset_network` | Reset Network | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 319 | `tool_tcp_optimizer_folder` | TCP Optimizer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 320 | `tool_furmark_setup` | FurMark Installer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 321 | `tool_prime95_folder` | Prime95 | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 322 | `tool_testmem5_folder` | TestMem5 | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 323 | `tool_fix_tools_change_name` | Change Name | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 324 | `tool_cleanmgrplus_folder` | Cleanmgr+ | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 325 | `tool_device_cleanup_folder` | Device Cleanup | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 326 | `tool_dismpp_folder` | Dism++ | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 327 | `tool_driver_store_explorer_folder` | Driver Store Explorer (RAPR) | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 328 | `tool_fix_tools_fastclean` | FastClean | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 329 | `tool_fix_tools_runner` | Fix Tools Launcher | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 330 | `tool_fix_tools_permessi` | Permessi | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 331 | `tool_power_settings_explorer` | PowerSettingsExplorer | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 332 | `tool_queue_size_tuner` | Queue Size Tuner | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 333 | `tool_fix_tools_ripristina_anteprime` | Ripristina Anteprime | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 334 | `tool_fix_tools_sfc_dism` | SFC & DISM | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 335 | `tool_unpark_cpu` | Unpark CPU | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 336 | `tool_vivetool_folder` | ViVeTool | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 337 | `tool_winslopr_releases` | Download Winslopr | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 338 | `tool_import_disable_advanced_services_profile` | Import Disable Advanced Services Profile | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 339 | `tool_import_minimal_services_profile` | Import Minimal Services Profile | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 340 | `tool_sysinternals_suite_winget` | Install Sysinternals Suite | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 341 | `tool_install_win11_debloat_raphire` | Install Win11 Debloat | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 342 | `tool_install_winhance` | Install Winhance | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 343 | `installers_menu` | Installers Menu | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 344 | `tool_winget_interactive_uninstaller` | Interactive App Uninstaller | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 345 | `tool_ctt_winutil` | Run CTT WinUtil | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |
| 346 | `tool_winscript_batch` | WinScript Batch Utility | Esperto | `external` | download/apertura on-demand; mantenere anche dopo la sostituzione nativa |

---

# Allegato B — Invarianti machine-readable da implementare

Il repository deve contenere, in una posizione scelta durante la Fase 0, una rappresentazione machine-readable equivalente all’Allegato A. I test devono verificare:

```text
legacyIdCount = 346
legacyIdUniqueCount = 346
legacyIdsWithoutDestination = 0
legacyIdsWithoutDisposition = 0
externalLegacyIds = 78
scriptVariantTitles = 37
directAliasCandidates = 23
```

Il file machine-readable è la sorgente dei test; questa tabella resta il contratto umano. Qualsiasi divergenza richiede aggiornamento coordinato e approvazione esplicita.
