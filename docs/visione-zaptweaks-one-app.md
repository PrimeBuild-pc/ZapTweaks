# Visione: ZapTweaks come unica app per preparare Windows 11

> Nota di prodotto per una prossima fase di progettazione. Nessuna implementazione prevista in questa fase.

## Idea centrale

ZapTweaks non dovrebbe limitarsi a lanciare CTT WinUtil, Winhance o altri tool esterni. L'obiettivo è diventare il punto unico, trasparente e reversibile per preparare un'installazione pulita di Windows 11, soprattutto su PC desktop da gaming.

L'utente installa ZapTweaks una sola volta e trova nello stesso posto:

- configurazione iniziale di Windows;
- installazione e rimozione delle app;
- gestione ragionata dei driver;
- ottimizzazione gaming, input, rete, grafica e alimentazione;
- diagnostica, monitoraggio e verifica;
- backup, ripristino e cronologia delle modifiche.

I tool esistenti sono riferimenti funzionali, non necessariamente dipendenze da incorporare. Dove possibile ZapTweaks dovrebbe replicare le funzioni con operazioni native, documentate e verificabili; gli strumenti esterni restano un fallback opzionale per ciò che non è ragionevole o sicuro reimplementare.

## Principio di prodotto

**Un solo pannello, operazioni leggibili, nessuna magia irreversibile.**

Ogni azione dovrebbe mostrare prima di essere applicata:

1. cosa cambia;
2. perché può essere utile;
3. impatto previsto su prestazioni, consumi, sicurezza e stabilità;
4. requisiti hardware o di edizione Windows;
5. come viene ripristinata;
6. se richiede riavvio o comporta una breve indisponibilità.

Le impostazioni dovrebbero essere raggruppate in profili comprensibili, ma sempre espandibili fino al singolo cambiamento. Evitare il modello "premi un bottone e applica 40 tweak sconosciuti".

## Esperienza iniziale: Windows appena installato

Un wizard opzionale di primo avvio dovrebbe guidare l'utente in questo ordine:

### 1. Inventario e baseline

- edizione e build di Windows 11;
- stato di attivazione, Secure Boot, TPM, VBS/HVCI e Defender;
- CPU, GPU, scheda madre, RAM, dischi, rete, monitor e periferiche;
- dispositivi senza driver o con driver generici Microsoft;
- driver installati, versioni, date, produttore e firma digitale;
- spazio libero, stato SMART quando disponibile e principali errori di sistema;
- programmi già presenti e app preinstallate;
- esportazione dei valori rilevanti prima di modificare il sistema.

La baseline deve poter essere salvata e confrontata con lo stato successivo. È utile anche per capire se un peggioramento deriva da ZapTweaks o da un aggiornamento successivo.

### 2. Scelta dell'obiettivo

Profili iniziali semplici, non marketing:

- **Uso quotidiano**: sicurezza e stabilità prima di tutto;
- **Gaming bilanciato**: ottimizzazioni a basso rischio senza sacrificare funzioni utili;
- **Gaming competitivo**: priorità a latenza e consistenza, con avvisi più espliciti;
- **Massime prestazioni**: impostazioni aggressive, da applicare solo dopo conferma;
- **Personalizzato**: scelta manuale per categoria.

Il profilo deve essere un punto di partenza e non un preset immutabile. Ogni profilo deve indicare chiaramente cosa non modifica.

### 3. Protezione e punto di ritorno

Prima delle operazioni ad alto impatto:

- creare un restore point quando disponibile;
- esportare registro, criteri e impostazioni gestite da ZapTweaks;
- salvare la lista dei driver e, se richiesto, esportare i driver già presenti;
- creare una cronologia locale delle azioni e del loro esito;
- avvisare se System Protection è disabilitata o se il backup non è stato possibile.

Il restore point non è un backup completo: l'interfaccia deve dirlo chiaramente e proporre, quando serve, un backup esterno o un'immagine di sistema.

### 4. Aggiornamenti di Windows

Il flusso dovrebbe distinguere tra:

- aggiornamenti di sicurezza;
- aggiornamenti qualitativi cumulativi;
- aggiornamenti delle feature;
- driver distribuiti tramite Windows Update.

Non bisogna consigliare di disabilitare Windows Update in modo permanente. L'utente deve poter mantenere gli aggiornamenti di sicurezza e applicare una sospensione o una policy temporanea solo quando sta preparando manualmente i driver.

## Sezione driver: area prioritaria per i PC gaming

Questa dovrebbe essere una delle differenze principali di ZapTweaks rispetto ai tool generici.

### Obiettivo

Permettere di preparare e mantenere una macchina con driver scelti consapevolmente, evitando che Windows sostituisca senza avviso un driver funzionante con uno generico o con una versione non desiderata.

### Funzioni previste

- rilevamento di tutti i componenti PnP e dei dispositivi sconosciuti;
- distinzione tra driver Microsoft generici, OEM e vendor ufficiale;
- report dei driver obsoleti, mancanti, duplicati o privi di firma valida;
- collegamenti alle pagine ufficiali di AMD, NVIDIA, Intel, Microsoft e del produttore della scheda madre/periferica;
- rilevamento della versione installata e confronto con la versione scelta dall'utente;
- supporto a pacchetti locali verificati, senza ospitare automaticamente driver di terze parti;
- verifica di firma digitale, produttore, versione e hash quando il pacchetto lo consente;
- installazione guidata per categoria, con checkpoint e riavvio controllato;
- log completo dell'installazione e risultato della verifica dopo il reboot;
- esportazione e ripristino della configurazione precedente;
- possibilità di bloccare temporaneamente gli aggiornamenti driver automatici tramite policy supportata;
- scadenza automatica o promemoria per riattivare il comportamento normale;
- verifica finale che la policy sia stata applicata e che non restino dispositivi in errore.

### Sequenza consigliata

1. completare gli aggiornamenti di Windows necessari;
2. creare baseline e punto di ripristino;
3. applicare, solo se richiesto, un blocco temporaneo degli aggiornamenti driver;
4. installare i driver in modo ordinato e con riavvii espliciti;
5. verificare Gestione dispositivi, Event Viewer essenziale e stabilità di rete/grafica/audio;
6. riattivare gli aggiornamenti driver oppure lasciare la policy attiva con scadenza e spiegazione;
7. salvare un profilo funzionante della macchina.

L'ordine esatto non deve essere imposto come verità universale: dipende da piattaforma, produttore e tipo di driver. ZapTweaks deve proporre un ordine motivato e permettere all'utente esperto di modificarlo.

### Guardrail driver

- Mai usare driver pack o mirror non verificati come comportamento predefinito.
- Mai bloccare indiscriminatamente Windows Update per ottenere un risultato gaming.
- Mai installare un driver solo perché è numericamente più recente.
- Non nascondere i limiti di Windows Home, delle policy disponibili o dei componenti OEM.
- Mostrare sempre se una modifica è temporanea, persistente o richiede rimozione manuale.
- Firmware, BIOS, VBIOS e flash di dispositivi restano operazioni separate e manuali; ZapTweaks può documentarle o aprire la fonte ufficiale, ma non deve flashare automaticamente.

## Funzionalità da assorbire dai tool esistenti

L'obiettivo è assorbire le capacità utili, non creare un contenitore di script copiati.

### Setup e debloat di Windows

Ispirazione: CTT WinUtil, Winhance, Wintoys, WTool.

- rimozione selettiva delle app preinstallate;
- installazione app tramite Windows Package Manager/winget quando disponibile;
- gestione delle app all'avvio;
- impostazioni privacy e diagnostica con descrizione dell'effetto reale;
- gestione di servizi, attività pianificate e componenti opzionali;
- configurazione di Esplora file, Start, taskbar e menu contestuali;
- associazioni e app predefinite;
- pulizia di file temporanei e cache con preview dello spazio recuperabile;
- gestione di Microsoft Store, Xbox e componenti opzionali senza rimuovere dipendenze alla cieca;
- comandi rapidi per strumenti nativi: Gestione dispositivi, Event Viewer, Autoruns se installato, PowerShell e Terminale.

### Policy e impostazioni avanzate

Ispirazione: Affinity Policy Tool e strumenti equivalenti.

- vista unificata delle policy che influenzano scheduling, priorità, rete, multimedia e gaming;
- spiegazione del percorso effettivo: registro, Group Policy, servizio o impostazione nativa;
- rilevamento dei conflitti tra policy locali, dominio/MDM e modifiche dell'utente;
- import/export di profili policy leggibili;
- ripristino esatto del valore precedente, non semplice impostazione di un valore "di default";
- filtro per rischio, categoria e compatibilità della build.

### Alimentazione e CPU

Ispirazione: Power Plan Explorer e strumenti per power plan.

- elenco dei piani presenti con confronto dei parametri rilevanti;
- importazione, duplicazione, attivazione ed eliminazione controllata dei piani;
- profili per desktop gaming, uso quotidiano e troubleshooting;
- visualizzazione dei parametri nascosti solo in modalità esperto;
- stato di boost, core parking e gestione minima/massima del processore;
- avviso quando un'impostazione aumenta consumi, temperature o usura;
- ripristino del piano usato prima dell'applicazione;
- verifica dopo il riavvio e indicazione del piano realmente attivo.

### GPU e dispositivi

Ispirazione: MSI Utility e utility di scheduling/interrupt.

- rilevamento GPU e driver vendor;
- accesso alle impostazioni supportate di Windows e ai pannelli ufficiali;
- MSI mode e interrupt affinity solo se il dispositivo e il driver lo supportano;
- backup dei valori originali e controllo che la modifica sia effettivamente applicata;
- impostazioni HAGS, ottimizzazioni per finestre, Game Mode e grafica per app;
- profili per gioco/app senza modifiche globali non necessarie;
- verifica di conflitti tra pannello NVIDIA/AMD/Intel e Windows;
- nessun overclock o modifica firmware automatica nella prima versione.

## Catalogo app e post-installazione

ZapTweaks dovrebbe includere un catalogo app curato, ma non diventare uno store proprietario.

### Categorie utili

- browser e comunicazione;
- launcher e store gaming;
- driver/control panel ufficiali;
- monitoring e diagnostica;
- compressione, codec e utility quotidiane;
- sviluppo e produttività;
- backup, sicurezza e password manager;
- audio, streaming e periferiche;
- runtime comuni come Visual C++ e .NET quando realmente necessari.

Per ogni app:

- fonte e publisher visibili;
- metodo di installazione;
- versione disponibile;
- licenza e tipo di distribuzione;
- checksum/firma quando possibile;
- installazione, aggiornamento, disinstallazione e stato;
- nessuna app sponsorizzata o bundled senza consenso esplicito.

L'uso di winget è il percorso naturale per il catalogo. I download diretti vanno usati solo quando la fonte è ufficiale e il pacchetto è verificabile.

## Monitoraggio continuo e verifica

Dopo la configurazione, ZapTweaks dovrebbe poter restare utile senza diventare un servizio pesante:

- dashboard di salute del sistema;
- confronto tra baseline e stato attuale;
- temperatura, utilizzo e clock con fonti affidabili;
- stato dei driver e dispositivi con errori;
- stato di Secure Boot, Defender, HVCI, firewall e aggiornamenti;
- rilevamento di policy o driver cambiati da Windows Update;
- controllo dei piani energetici e delle app in avvio;
- avvisi solo per anomalie concrete, non notifiche continue;
- modalità diagnostica esportabile per chiedere supporto.

Il monitoraggio dovrebbe essere disattivabile e non richiedere un servizio residente se non indispensabile.

## Centro sicurezza e affidabilità

Le ottimizzazioni non devono incentivare una macchina insicura.

- stato e spiegazione di Defender, firewall, SmartScreen, Secure Boot, TPM e VBS;
- suggerimenti con distinzione netta tra "consigliato", "opzionale" e "riduce la sicurezza";
- nessuna disattivazione silenziosa di Defender o delle protezioni;
- avviso speciale per esclusioni antivirus, HVCI, VBS, UAC e servizi di sicurezza;
- verifica di BitLocker e avviso prima di operazioni che possono richiedere chiavi di ripristino;
- controllo di spazio, salute del disco e affidabilità del sistema;
- indicazione delle impostazioni gestite da organizzazione o dominio che ZapTweaks non deve sovrascrivere.

## Modello operativo interno da progettare

Per evitare di trasformare il progetto in una raccolta incontrollabile di script, ogni modifica dovrebbe avere una scheda strutturata con almeno:

- ID stabile e versione;
- categoria e compatibilità;
- prerequisiti;
- livello di rischio;
- descrizione tecnica e descrizione semplice;
- lettura dello stato attuale;
- applicazione;
- verifica post-applicazione;
- rollback con i valori precedenti;
- richiesta di riavvio;
- fonte/documentazione;
- conflitti noti;
- log e codice di errore.

Il motore dovrebbe comporre un **piano di applicazione** prima di eseguirlo: mostrare modifiche, conflitti, riavvii e rischi, chiedere conferma e poi applicare in ordine. Se un passaggio fallisce, il risultato deve essere chiaro e il piano non deve fingere di essere completato.

## Profili, snapshot e ripristino

Funzioni che aumenterebbero molto il valore dell'app:

- snapshot nominati, esportabili e importabili;
- profilo "prima del gaming" e "uso quotidiano";
- confronto tra due snapshot;
- rollback per singola azione o per gruppo;
- log filtrabile con timestamp, utente, versione app e build Windows;
- modalità dry-run sempre disponibile quando tecnicamente possibile;
- report Markdown/JSON per supporto e troubleshooting;
- possibilità di annullare un profilo senza cancellare impostazioni modificate manualmente in seguito, quando il rilevamento lo consente.

## Architettura di navigazione futura

Una struttura coerente potrebbe essere:

1. **Home / Stato** — salute, hardware, avvisi e attività recenti;
2. **Setup Windows** — wizard, privacy, debloat, shell e impostazioni di base;
3. **Driver** — inventario, policy, installazione, verifica e rollback;
4. **App** — catalogo, installazione, aggiornamento e rimozione;
5. **Gaming** — profili, input, grafica, servizi e ottimizzazioni;
6. **Power & CPU** — piani e parametri energetici;
7. **Rete** — adapter, DNS, TCP e diagnostica;
8. **Windows policies** — policy, servizi e impostazioni avanzate;
9. **Monitoraggio** — salute, eventi, driver e cambiamenti;
10. **Recovery** — restore point, snapshot, backup e strumenti di riparazione;
11. **Expert** — operazioni ad alto rischio, nascoste di default;
12. **Settings / Sources** — fonti, aggiornamenti, privacy, log e preferenze.

## Cosa non fare

- Non copiare indiscriminatamente script o codice di altri progetti.
- Non incorporare tool con licenze incompatibili o senza verificare la provenienza.
- Non eseguire script remoti mutabili con pattern tipo `irm ... | iex` come percorso standard.
- Non promettere aumenti universali di FPS o riduzioni certe della latenza.
- Non usare valori di registro globali quando esiste una configurazione per-app o per-profilo.
- Non applicare modifiche cumulative senza mostrare l'elenco dei cambiamenti.
- Non disabilitare aggiornamenti, sicurezza o servizi essenziali senza un avviso specifico e un modo chiaro per tornare indietro.
- Non trasformare ZapTweaks in un antivirus, un driver host o un tool di flashing firmware.

## Roadmap concettuale

### Fase 1 — Fondamenta

- modello comune delle azioni;
- stato, backup, verifica, rollback e log;
- inventario hardware/Windows;
- profili e piano di applicazione;
- distinzione tra impostazioni supportate, sperimentali e non applicabili.

### Fase 2 — Setup completo

- wizard post-installazione;
- debloat selettivo;
- privacy, shell, app predefinite e manutenzione;
- catalogo app tramite winget;
- snapshot iniziale e report finale.

### Fase 3 — Driver

- inventario e salute driver;
- blocco temporaneo dei driver via policy;
- workflow di installazione/verifica;
- monitoraggio delle sostituzioni dopo Windows Update;
- rollback e profili per macchina.

### Fase 4 — Gaming e diagnostica

- profili per gioco/app;
- grafica, input, rete, CPU e power plan;
- verifica concreta delle impostazioni;
- monitoraggio leggero e troubleshooting esportabile.

### Fase 5 — Expert e manutenzione

- policy avanzate;
- attività pianificate e servizi con dipendenze visibili;
- automazioni schedulate e scadenze;
- pacchetto di supporto e confronto tra installazioni.

## Decisioni da chiarire prima di implementare

- Quali categorie entrano nella prima versione "one app" e quali restano future?
- ZapTweaks deve funzionare anche offline dopo il download iniziale?
- Il catalogo app usa solo winget o supporta anche pacchetti ufficiali verificati?
- Qual è il livello minimo di supporto per Windows 11 Home rispetto a Pro?
- Quanto deve essere automatica la gestione dei driver e quanto deve restare approvazione manuale?
- Quali impostazioni sono scientificamente verificabili e quali devono essere marcate come sperimentali?
- Serve un database locale delle azioni/versioni o basta un catalogo compilato nell'app?
- Quali operazioni richiedono obbligatoriamente restore point, backup o doppia conferma?

## Criterio di successo

Un utente che installa Windows 11 su un desktop da gaming dovrebbe poter aprire ZapTweaks, capire lo stato della macchina, scegliere un obiettivo, installare le app necessarie, configurare Windows e i driver, verificare il risultato e tornare indietro senza usare cinque utility diverse né copiare script trovati online.

La promessa non è "più tweak degli altri": è **meno strumenti, meno sorprese, più controllo verificabile**.
