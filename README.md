# Focus on your own life

**Focus on your own life** è un'app sperimentale per la produttività costruita in Flutter. Trasforma una limitazione hardware (non toccare il telefono) in una meccanica di *gamification* per mantenere la concentrazione durante lo studio o il lavoro.

Non è il solito timer Pomodoro: **Zen Focus sa se stai barando.** Se prendi in mano il telefono prima che il tempo scada, l'app se ne accorge, cancella la tua sessione e ti "punisce" con un allarme visivo e tattile.

## Funzionalità Principali

*  **Gesture-Based UI:** Nessun tastierino numerico noioso. Fai uno *swipe verso l'alto o verso il basso* sulla schermata principale per impostare i minuti del tuo timer.
*  **Controllo Accelerometro:** Sfrutta l'accelerometro dello smartphone per monitorare l'inclinazione (assi X e Y). Il timer parte solo quando il telefono è appoggiato su una superficie piana.
*  **Busted Mode (Feedback Punitivo):** Se sollevi o inclini il telefono durante una sessione attiva, l'app interrompe il timer, fa lampeggiare la **torcia** 3 volte e attiva una forte **vibrazione**.
*  **Feedback di Successo:** Se resisti e completi la sessione senza toccare il device, verrai premiato con una vibrazione breve e ritmata.

## Tecnologie e Dipendenze

Il progetto è realizzato in [Flutter](https://flutter.dev/) e utilizza i seguenti pacchetti esterni:

* [`sensors_plus`](https://pub.dev/packages/sensors_plus): Per leggere i dati dell'accelerometro in tempo reale.
* [`vibration`](https://pub.dev/packages/vibration): Per gestire il feedback aptico e le vibrazioni personalizzate.
* [`torch_light`](https://pub.dev/packages/torch_light): Per far lampeggiare il flash della fotocamera.

## Come avviare il progetto

### Prerequisiti
Assicurati di aver installato Flutter sul tuo sistema.
**Nota molto importante:** Per testare correttamente le funzionalità di base (Sensori, Vibrazione e Torcia), è **fortemente consigliato utilizzare un dispositivo fisico** (Android o iOS) al posto di un emulatore, poiché gli emulatori non supportano la torcia e faticano a simulare accuratamente i sensori di movimento.

### Installazione

1. Clona questo repository o scarica i file sorgente.
2. Apri il terminale nella directory del progetto.
3. Scarica le dipendenze eseguendo:
   ```bash
   flutter pub get
(Se i pacchetti non sono ancora nel tuo pubspec.yaml, puoi aggiungerli rapidamente con flutter pub add sensors_plus vibration torch_light)
4. Collega il tuo smartphone tramite cavo o debug Wi-Fi.
5. Avvia l'app:

Bash
flutter run
 Come si usa
All'apertura, usa il dito per fare swipe in su o in giù sullo schermo per impostare i minuti del timer.

Premi il bottone START. L'app entrerà in stato di "Attesa".

Appoggia il telefono su una scrivania o su un piano (a faccia in su o in giù).

Appena il telefono sarà perfettamente immobile e in bolla, il timer partirà in automatico.

Non toccarlo! Se lo alzi, l'allarme scatterà.

Progetto realizzato come esperimento per testare l'integrazione di sensori hardware (Accelerometro) e Gesture in Flutter.



## Progettazione

    Focus_on_your_own_life/
    │
    ├── android/                 # Codice nativo Android
    │   └── app/src/main/
    │       └── AndroidManifest.xml  <-- (Qui aggiungi i permessi per la vibrazione)
    │
    ├── ios/                     # Codice nativo iOS
    │   └── Runner/
    │       └── Info.plist           <-- (Qui aggiungi i permessi per la torcia/fotocamera)
    │
    ├── lib/                     #  TUTTO IL TUO CODICE DART VA QUI 
    │   │
    │   ├── main.dart            # Punto di ingresso dell'app (runApp)
    │   │
    │   ├── screens/             # Schermate intere dell'app
    │   │   └── focus_screen.dart    # La UI del timer e la gestione degli stati
    │   │
    │   ├── widgets/             # Componenti riutilizzabili (opzionale per ora)
    │   │   └── timer_circle.dart    # Es: Il widget del cerchio animato estratto
    │   │
    │   └── services/            # Logica che non riguarda la grafica
    │       └── hardware_feedback.dart # Es: Le funzioni per torcia e vibrazione
    │
    ├── test/                    # File per i test automatici
    │
    ├── pubspec.yaml             #  Il file fondamentale per le dipendenze
    │
    └── README.md                #  Il file di documentazione che abbiamo appena creato
