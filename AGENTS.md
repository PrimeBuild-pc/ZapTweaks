\# AGENTS.md



\## Ambiente

Sviluppo su Windows 11. Preferisci PowerShell per comandi Windows-native.

Per Flutter desktop usa `flutter doctor`, `flutter test`, `flutter build windows`.

Per .NET usa `dotnet build`, `dotnet test`, `dotnet format`.



\## Regole generali

\- Prima di modificare codice, analizza la struttura del progetto.

\- Fai modifiche piccole e verificabili.

\- Non cambiare framework o architettura senza motivazione.

\- Dopo modifiche importanti esegui build e test.

\- Per API Microsoft/.NET usa Microsoft Learn MCP.

\- Per package e framework aggiornati usa Context7.

\- Per siti web usa Playwright MCP per smoke test.

\- Per UI da design usa Figma MCP se disponibile.



\## Windows desktop

\- WPF: preferisci MVVM, command binding, dependency injection, async/await corretto.

\- WinForms: separa logica UI da servizi; evita business logic nei form.

\- .NET: usa nullable reference types, logging, options pattern e test dove sensato.



\## Flutter

\- Mantieni widget piccoli e composabili.

\- Se il progetto ha già uno state management, non cambiarlo.

\- Controlla compatibilità plugin con Windows.

