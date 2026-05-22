# Documentație Tehnică - BitStride

**BitStride** este o suită de aplicații software educaționale destinată facilitării învățării limbajelor de programare C++ și Python de către elevii de liceu și studenți. Sistemul este compus din două aplicații complementare:
1. **BitStride Core** (Aplicația Mobilă/Web pentru Eleve/Elevi) - O platformă gamificată, dotată cu vizualizator de algoritmi de sortare în timp real, lecții interactive și un compilator integrat.
2. **BitStride Studio** (Portalul Administrativ) - O consolă pentru profesori și creatori de conținut pentru proiectarea provocărilor de codare, gestionarea cursurilor, definirea seturilor de teste de evaluare și recenzarea manuală sau automată a trimiterilor de cod.

---

## 1. Valoarea Educațională (De ce și unde ajută elevii / liceenii)

BitStride rezolvă probleme acute ale procesului clasic de învățare a informaticii în licee și universități:
* **Corecție Automată Instantanee**: Elevii primesc feedback imediat prin intermediul sistemului automat de testare ("Judge"). Acest lucru reduce decalajul dintre scrierea codului și identificarea erorilor logice, simulând platformele de tip olimpiadă (PBInfo, InfoArena), dar într-un format accesibil direct pe mobil sau web.
* **Vizualizare Algoritmică în Timp Real**: Elevii pot urmări animații detaliate pas-cu-pas ale algoritmilor de sortare fundamentali (Bubble Sort, Quick Sort, Merge Sort, Insertion Sort, Selection Sort). Modul de vizualizare oferă posibilitatea de pauză, control al vitezei de execuție și evidențiere cromatică a elementelor comparate sau interschimbate, transformând noțiunile teoretice abstracte în reprezentări vizuale intuitive.
* **Gamificare și Consistență**: Sistemul integrează elemente specifice jocurilor (puncte de experiență - XP, streak zilnic de activitate, clasament săptămânal/leaderboard) concepute să stimuleze competiția constructivă și menținerea unui ritm constant de studiu.
* **Sandbox Securizat**: Elevii pot experimenta cu cod fără a fi nevoiți să instaleze compilatoare complexe sau IDE-uri pe computerele sau telefoanele proprii, fiind ideal pentru elevii care nu dispun de echipamente performante acasă.

---

## 2. Arhitectura Sistemului și Componente Cheie

Sistemul utilizează o arhitectură distribuită bazată pe servicii cloud și compilare descentralizată:

### A. Evaluatorul de Cod (Piston API)
* Toată compilarea și execuția de cod se efectuează la distanță prin intermediul **Piston API** (un motor de execuție izolat și securizat).
* Codul trimis de elev este rulat în containere izolate temporar, cu limite stricte de timp (Implicit: 10 secunde) și memorie (ex: 64MB - 128MB), detectând erori specifice precum `Time Limit Exceeded` (Tle), `Memory Limit Exceeded` (Mle), `Segmentation Fault` (erori de pointeri/acces memorie) sau `Division by Zero`.

### B. Securitate și Conectivitate (Cloudflare Tunnel)
* Pentru a evita expunerea publică a serverului privat de compilare (Piston) și riscurile asociate atacurilor cibernetice, se folosește tehnologia **Cloudflare Tunnel** (`cloudflared`).
* Aceasta permite rutarea securizată a apelurilor API HTTPS dinspre aplicația Flutter către serverul Piston local printr-un canal criptat bidirecțional, fără a necesita deschiderea de porturi în router (port forwarding) sau adrese IP publice statice.
* URL-ul tunelului activ este publicat de administrator în baza de date securizată Firestore, iar aplicația client îl preia dinamic la pornire.

### C. Stocare Cloud și Autentificare (Firebase Firestore & Firebase Auth)
* **Firestore**: Bază de date de tip document-store (NoSQL) utilizată pentru stocarea profilurilor de utilizatori, clasamentelor, cursurilor oficiale și provocărilor personalizate create în Studio.
* **Firebase Auth**: Gestionează înregistrarea, conectarea securizată și sincronizarea datelor elevilor pe mai multe dispozitive folosind credențiale de e-mail/parolă sau Google Sign-In.

### D. Serviciul de Traducere (Multi-Language Service)
* Pentru flexibilitatea cursurilor, BitStride suportă limba Română, Engleză, Franceză, Spaniolă și Portugheză.
* Interfața fixă folosește fișiere locale tip `.arb` compilate automat prin `flutter gen-l10n`.
* Textele dinamice ale lecțiilor sunt traduse utilizând biblioteca `translator` (Google Translate API) pe mobil, iar pe varianta Web se folosește un proxy către API-ul **MyMemory** (`mymemory.translated.net`) pentru a depăși restricțiile de partajare a resurselor între origini (CORS).

---

## 3. Fișiere Sensibile și Securitatea Depozitului de Cod

> [!WARNING]
> Toate fișierele de configurare sensibile și cheile private de acces au fost eliminate din depozitul de cod (repository) înainte de publicare. Acesea includ:
> * `google-services.json` (Android Firebase Config)
> * `firebase_options.dart` (Configurații automate Flutter pentru Firebase)
> * Fișiere de mediu `.env` și keystore-uri de semnare.
>
> Proiectele **nu pot fi compilate direct** fără ca aceste fișiere să fie re-generate și plasate în directoarele corespunzătoare conform Ghidului de Configurare Firebase.

---

## 4. Cerințe de Sistem

### Cerințe Minime (Rulare Aplicație)
* **Android**: Versiunea 6.0 (Marshmallow - API 23), 2 GB memorie RAM.
* **Web**: Browser capabil de WebGL și Canvas (Chrome 90+, Safari 14+, Firefox 90+).

### Configurație Recomandată (Dezvoltare & Compilare)
* **OS**: Windows 10/11 pe 64 de biți sau macOS Sonoma.
* **IDE**: VS Code (cu extensiile Flutter & Dart) sau Android Studio.
* **SDK**: Flutter SDK 3.22.x sau superior, Dart SDK 3.5.4+.
* **Instanță Evaluator (Piston)**: Server Linux/Docker local cu motorul Piston activat pe portul 2001 și tunel Cloudflare funcțional.

---

## 5. Ghid de Implementare și Recomandare Găzduire Web

* **Găzduire Versiune Web**: Este recomandat ca ambele aplicații (Core și Studio) în varianta web să fie construite utilizând comanda `flutter build web --release` și găzduite pe **GitHub Pages**.
* Pentru a asigura rutarea corectă pe GitHub Pages (care nu suportă nativ configurările SPA cu rute de tip clean URL), se sugerează utilizarea strategiei de hash-routing (`usePathUrlStrategy` dezactivat) sau un script de tip SPA redirection wrapper (`404.html` redirecționând către `index.html` cu parametri query).
