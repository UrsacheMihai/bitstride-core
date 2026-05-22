# BitStride Core

## Informatii generale

* **Categorie**: Educational
* **Judetul**: Brăila
* **Surse**: GitHub - [UrsacheMihai/bitstride-core](https://github.com/UrsacheMihai/bitstride-core)

## Descriere

“BitStride Core” este o aplicație educațională mobilă și web interactivă și gamificată, destinată facilitării învățării limbajelor de programare C++ și Python de către elevii de liceu și studenți. Aplicația oferă o platformă completă cu vizualizator de algoritmi de sortare în timp real, lecții interactive și un compilator integrat securizat.

Concret, aceasta îi permite utilizatorului:
* să înțeleagă vizual, pas-cu-pas, cum funcționează algoritmii fundamentali de sortare și comparare a elementelor;
* să rezolve provocări practice de codare în C++ și Python direct de pe dispozitivul mobil sau din browser, fără configurări locale dificile;
* să parcurgă lecții interactive structurate sub formă de hartă de studiu și să primească feedback instant pe marginea testelor de evaluare;
* să își mențină motivația de a învăța prin elemente de gamificare (XP, streak zilnic de activitate, clasamente).

## Funcționalități

### Învățare interactivă
* **Harta Curriculei**: O interfață vizuală bazată pe o hartă de parcurs a lecțiilor de programare.
* **Documentație și suport**: Lecții clare, cu suport multilingv (inclusiv Română) și exemple practice direct în pagină.

### Vizualizator de Algoritmi de Sortare (Playground)
* Modul grafic pentru redarea vizuală a pașilor algoritmilor: Bubble Sort, Quick Sort, Merge Sort, Insertion Sort, Selection Sort.
* Controlul vitezei de execuție, posibilitate de pauză/redare și evidențierea elementelor comparate și interschimbate pentru o învățare intuitivă.

### Sistem Inteligent de Evaluare (Judge Client)
* **Compilare la distanță**: Integrare securizată cu un compiler judge la distanță (Piston API), cu limite stricte de timp (10s) și memorie (64MB) pentru a preveni buclele infinite sau utilizarea abuzivă a resurselor.
* **Feedback live**: Afișarea detaliată a rezultatelor rulării pe testele de evaluare în timp real.
* **Salvare automată**: Starea și progresul utilizatorului (inclusiv codurile scrise) sunt salvate automat local (SQLite) și sincronizate în cloud (Firestore).

### Meniu de Setări și Profil
* Profil personalizat care urmărește experiența totală (XP), cel mai lung streak și insignele (badges) deblocate.
* Setări pentru controlul volumului audio și alegerea limbii (Română, Engleză, Spaniolă, Franceză, Portugheză).

---

## Tehnologii

Aplicația “BitStride Core” a fost construită folosind:
* **Flutter SDK 3.22.x+** - Cadru pentru construirea interfeței native multi-platformă.
* **Dart 3.5.4+** - Limbaj de programare modern și reactiv.
* **SQLite (via sqflite)** - Caching local pentru stocarea offline a lecțiilor, progresului și testelor de cod.
* **Cloud Firestore & Firebase Auth** - Sincronizare în timp real a datelor și autentificare securizată (E-mail/Google).
* **Piston Compiler API & Cloudflare Tunnel** - Evaluarea securizată și izolată a codului în containere Docker.

---

## Cerinte sistem

* **Sistem de operare**: Android 6.0 (API 23) sau superior / Browser modern capabil de WebGL și Canvas (Chrome, Safari, Firefox).
* **Conectare internet**: Recomandată pentru autentificare, sincronizare și evaluarea codului.

---

## Realizatori

**Ursache Mihai-Andrei**
* **Scoala**: Colegiul Național „Nicolae Iorga” Brăila
* **Clasa**: a X-a
* **Judet**: Brăila
* **Oras**: Brăila

---

## Documentație Tehnică & Wiki

Pentru detalii profunde despre arhitectură, componente și structură, consultați:
* [Developer Wiki (EN)](wikis/bitstride_core_wiki.md)
* [Developer Wiki (RO)](wikis/bitstride_core_wiki_ro.md)
* [Documentație Tehnică (RO)](wikis/documentatie_tehnica.md)
* [Componente Nerealizate (RO)](wikis/componente_nerealizate.txt)
