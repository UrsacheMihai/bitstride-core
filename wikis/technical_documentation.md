# Technical Documentation - BitStride

**BitStride** is an educational software suite designed to facilitate learning C++ and Python programming languages for high school and university students. The system consists of two complementary applications:
1. **BitStride Core** (Learner Mobile/Web App) - A gamified platform featuring a real-time sorting algorithm visualizer, interactive lessons, and an integrated compiler sandbox.
2. **BitStride Studio** (Admin Portal) - An administrative console for teachers and content creators to design coding challenges, manage courses, define test suites, and review student code submissions manually or automatically.

---

## 1. Educational Value Proposition (How and Where it Helps Students)

BitStride solves acute problems in modern computer science classrooms:
* **Instant Automated Grading**: Students receive immediate feedback from the automated testing judge. This bridges the gap between writing code and finding logic errors, simulating high school olympiad platforms (like PBInfo, InfoArena) in a accessible mobile-friendly sandbox.
* **Real-time Algorithmic Visualizer**: Students can watch detailed, step-by-step animations of fundamental sorting algorithms (Bubble Sort, Quick Sort, Merge Sort, Insertion Sort, Selection Sort). The visualizer provides pause/play controls, execution speed adjustment, and color highlighting for active comparisons or swaps, turning abstract theories into intuitive visualizations.
* **Gamification & Consistence**: The system integrates game elements (XP points, active daily streaks, weekly leaderboards) designed to motivate students and build consistent study habits.
* **Secure Compiler Sandbox**: Learners can write and execute code without installing compilers or local IDEs on their own devices, which is perfect for students who do not own high-performance computers.

---

## 2. System Architecture & Key Components

The system employs a distributed service architecture with client-side databases and decentralized remote code execution:

### A. Code Evaluator (Piston API)
* Code compilation and execution are offloaded to **Piston API** (a secure, lightweight open-source execution engine).
* The user's code runs in isolated Docker containers with strict execution time limits (Default: 10s) and virtual memory limits (e.g. 64MB - 128MB), capturing errors like `Time Limit Exceeded` (Tle), `Memory Limit Exceeded` (Mle), `Segmentation Fault` (memory errors), or `Division by Zero`.

### B. Secure Connectivity (Cloudflare Tunnel)
* To protect the local/private compiler server (Piston) from exposure to public port scans and DDoS risks, we utilize **Cloudflare Tunnel** (`cloudflared`).
* This establishes a secure, encrypted bi-directional tunnel routing HTTPS API payloads from the Flutter client to the local Piston container without open firewall ports or static public IPs.
* The active tunnel URL is published to Firestore by the admin, and client apps read it dynamically at startup.

### C. Cloud Storage & Authentication (Firebase Firestore & Firebase Auth)
* **Firestore**: Document-store NoSQL database tracking user profiles, leaderboard scores, official curricula, and custom user-generated challenges.
* **Firebase Auth**: Manages secure email/password registration, login sessions, and Google Sign-In, synchronizing progress across multiple student devices.

### D. Localization & Translation (Multi-Language Service)
* BitStride supports English, Romanian, French, Spanish, and Portuguese.
* Static translations are built using `.arb` files compiled via `flutter gen-l10n`.
* Dynamic course and lesson markdown strings are translated using the `translator` package (Google Translate API) on mobile clients, and fallback to the public **MyMemory Translation API** (`mymemory.translated.net`) on Web to bypass Cross-Origin Resource Sharing (CORS) limits.

---

## 3. Sensitive Configuration Files & Repository Security

> [!WARNING]
> All sensitive credentials and access tokens have been completely stripped from the repository prior to publishing. These include:
> * `google-services.json` (Android Firebase Config)
> * `firebase_options.dart` (Flutter Firebase options config)
> * Active environment `.env` settings and keystore signing properties.
>
> The projects **cannot be built or compiled** directly from GitHub/Gitea without generating and replacing these files in their respective folders.

---

## 4. System Requirements

### Minimum Requirements (End-User App)
* **Android**: Version 6.0 (API 23), 2 GB RAM.
* **Web**: Modern HTML5 browser with WebGL/Canvas support (Chrome 90+, Safari 14+, Firefox 90+).

### Recommended Configurations (Developer Compiler Env)
* **OS**: 64-bit Windows 10/11 or macOS Sonoma.
* **IDE**: VS Code (with Flutter & Dart extensions) or Android Studio.
* **SDK**: Flutter SDK 3.22.x or newer, Dart SDK 3.5.4+.
* **Code Judge (Piston)**: Local Linux/Docker container instance listening on port 2001 with active Cloudflare Tunnel proxy routing.

---

## 5. Deployment Guidelines & Web Hosting

* **Web Hosting**: It is highly recommended to build the web release of both projects using `flutter build web --release` and host them on **GitHub Pages**.
* To prevent routing problems on GitHub Pages (which does not support SPA rewrite configurations natively), we recommend using hash routing (`usePathUrlStrategy` disabled) or deploying a custom redirect script using `404.html` forwarding parameters back to `index.html`.
