# 🎙️ Recorder — Offline Speech-to-Text & Document Scanner OCR

Application mobile Flutter moderne, puissante et **100% hors-ligne (On-Device)**, combinant la transcription audio haute fidélité via **Whisper.cpp** et la numérisation intelligente de documents couplée à un moteur OCR **PaddleOCR (NCNN)**.

Aucune donnée audio, textuelle ou image ne transite par un serveur externe : tout le traitement est exécuté localement sur l'appareil pour garantir une confidentialité absolue et des performances optimales sans connexion Internet.

---

## 📑 Sommaire

- [✨ Fonctionnalités Principales](#-fonctionnalités-principales)
  - [1. Transcription Audio (Speech-to-Text)](#1-transcription-audio-speech-to-text)
  - [2. Scanner de Documents & OCR Hors-Ligne](#2-scanner-de-documents--ocr-hors-ligne)
- [🏗️ Architecture du Projet](#️-architecture-du-projet)
- [⚙️ Prérequis & Environnement](#️-prérequis--environnement)
- [🚀 Installation & Configuration](#-installation--configuration)
- [📦 Compilation & Build Android](#-compilation--build-android)
- [🧠 Modèles Embarqués & Gestion Mémoire](#-modèles-embarqués--gestion-mémoire)
- [🛠️ Résolution des Problèmes Courants](#️-résolution-des-problèmes-courants)

---

## ✨ Fonctionnalités Principales

### 1. Transcription Audio (Speech-to-Text)
- **Moteur Whisper On-Device** : Inférence basée sur `whisper.cpp` (via `whisper_cpp_flutter_plus`).
- **Enregistrement en direct** : Capture micro temps réel avec streaming de flux PCM 16 kHz.
- **Importation de fichiers multimédias** : Support étendu de conteneurs et codecs (`WAV`, `MP3`, `M4A`, `AAC`, `OGG`, `OPUS`, `FLAC`, `WMA`, `WEBM`, `MP4`).
- **Conversion audio automatique (FFmpeg)** : Prétraitement et rééchantillonnage dynamique en WAV mono 16 kHz PCM via `ffmpeg_kit_flutter_new`.
- **Catalogue de modèles Whisper modulaires** :
  - `Tiny` / `Tiny EN` (~75 Mo) : Inférence ultra-rapide, idéale pour les appareils modestes.
  - `Base` / `Base EN` (~142 Mo) : Excellent compromis entre vitesse et précision.
  - `Small` (~465 Mo) : Haute fidélité multilingue.
  - `Medium` (~1.4 Go) : Précision maximale pour transcriptions complexes.
  - Téléchargement à la demande avec jauge de progression et persistance en cache local.
- **Support multilingue** : Détection automatique de langue (`auto`), Français (`fr`), Anglais (`en`).
- **Horodatages précis** : Génération de segments avec `tokenTimestamps`.

### 2. Scanner de Documents & OCR Hors-Ligne
- **Numérisation native assistée par ML Kit** : Intégration du scanner officiel Google ML Kit (`google_mlkit_document_scanner`) avec détection automatique des contours, redressement de perspective, recadrage intuitif et filtres d'amélioration.
- **Import Galerie** : Numérisation directe via caméra ou sélection de documents existants.
- **Moteur OCR PP-OCRv5 Mobile (NCNN)** :
  - Inférence ultra-légère et rapide basée sur PaddleOCR optimisé NCNN (`fast_paddle_ocr`).
  - Détection (`PP_OCRv5_mobile_det`) et Reconnaissance (`PP_OCRv5_mobile_rec`) embarquées directement dans les assets de l'application.
  - Extraction de texte instantanée avec copie directe dans le presse-papiers.

---

## 🏗️ Architecture du Projet

Le projet suit une organisation claire séparant la logique métier (Services), les structures de données (Models) et l'interface utilisateur (Screens & Widgets) :

```text
recorder/
├── assets/
│   └── ocr_models/                       # Modèles binaires NCNN pour PaddleOCR
│       ├── PP_OCRv5_mobile_det.ncnn.bin
│       ├── PP_OCRv5_mobile_det.ncnn.param
│       ├── PP_OCRv5_mobile_rec.ncnn.bin
│       └── PP_OCRv5_mobile_rec.ncnn.param
├── android/
│   ├── app/
│   │   ├── build.gradle.kts              # Config NDK 29+, minSdk 24, ABI splits
│   │   └── src/main/AndroidManifest.xml  # Permissions audio & configuration
├── lib/
│   ├── main.dart                         # Point d'entrée de l'application
│   ├── models/
│   │   ├── scan_page.dart                # Modèle de page numérisée & statut OCR
│   │   ├── transcription_job.dart        # Modèle de tâche de transcription
│   │   └── whisper_options.dart          # Définition des modèles Whisper & langues
│   ├── services/
│   │   ├── audio_recorder_service.dart   # Capture microphone & gestion des buffers PCM
│   │   ├── document_scanner_service.dart # Wrapper du scanner ML Kit
│   │   ├── ocr_service.dart              # Déploiement des assets & inférence PaddleOCR
│   │   └── transcription_service.dart    # WhisperEngine & conversion FFmpeg
│   ├── screens/
│   │   ├── root_screen.dart              # Navigation principale (IndexedStack)
│   │   ├── transcribe/                   # Module Transcription (Vue, Sélecteurs, Cartes)
│   │   │   ├── transcribe_screen.dart
│   │   │   └── widgets/
│   │   └── scan/                         # Module Scanner & OCR (Vue, Cartes de pages)
│   │       ├── scan_screen.dart
│   │       └── widgets/
│   └── theme/
│       └── app_theme.dart                # Thème Material 3 (clair / sombre)
└── pubspec.yaml                          # Dépendances et contraintes SDK
```

---

## ⚙️ Prérequis & Environnement

Pour compiler et exécuter le projet, votre environnement de développement doit satisfaire les critères suivants :

| Composant | Version minimale requise | Commentaire |
| :--- | :--- | :--- |
| **Flutter SDK** | `>= 3.22.0` | Compatible avec Dart `>= 3.3.0 < 4.0.0` |
| **Dart SDK** | `>= 3.3.0` | Inclus dans le SDK Flutter |
| **Java JDK** | `17` | Requis pour le build Gradle Android |
| **Android NDK** | `29.0.14206865`+ | **Obligatoire** pour la compilation C++ NCNN de `fast_paddle_ocr` |
| **Android Min SDK** | `API 24` (Android 7.0) | Imposé par `ffmpeg_kit_flutter_new` |

---

## 🚀 Installation & Configuration

1. **Cloner le projet** :
   ```bash
   git clone <url-du-depot>
   cd recorder
   ```

2. **Installer les dépendances Flutter** :
   ```bash
   flutter pub get
   ```

3. **Vérifier l'installation du NDK Android** :
   Assurez-vous que le composant **NDK (Side by side)** version **29.x** est bien installé via Android Studio SDK Manager (`Tools > SDK Manager > SDK Tools > NDK (Side by side)`). Le chemin est référencé dans `android/app/build.gradle.kts` :
   ```kotlin
   android {
       ndkVersion = "29.0.14206865"
       ...
   }
   ```

---

## 📦 Compilation & Build Android

L'application intégrant des librairies C++ natives volumineuses (FFmpeg, Whisper.cpp, NCNN), **il est fortement recommandé de compiler avec `--split-per-abi`**. Cela génère un APK distinct par architecture matérielle et évite un APK final trop lourd.

### Build APK (Recommandé)
```bash
flutter build apk --split-per-abi
```
Les APK générés se trouvent dans :
`build/app/outputs/flutter-apk/` :
- `app-arm64-v8a-release.apk` (appareils modernes 64-bit)
- `app-armeabi-v7a-release.apk` (appareils 32-bit plus anciens)
- `app-x86_64-release.apk` (émulateurs et appareils x86_64)

### Build App Bundle (Google Play Store)
```bash
flutter build appbundle
```

---

## 🧠 Modèles Embarqués & Gestion Mémoire

### Modèles OCR (NCNN)
Les fichiers du modèle `PP-OCRv5` sont distribués directement dans `assets/ocr_models/` :
- Au premier lancement de l'onglet Scanner, `OcrService.ensureModelLoaded()` extrait automatiquement ces binaires vers le répertoire local sécurisé de l'application (`getApplicationSupportDirectory()`) afin qu'ils soient lisibles directement par la librairie native NCNN.

### Modèles Whisper
- Les modèles Whisper sont téléchargés à la demande par l'utilisateur lors du premier usage du modèle sélectionné.
- Ils sont enregistrés dans le cache applicatif via `WhisperModelManager` et restent immédiatement disponibles pour les sessions suivantes, même sans connexion réseau.

---

## 🛠️ Résolution des Problèmes Courants

### 1. Erreur de résolution de version Dart (`sdk version ^3.14.0...`)
Si vous rencontrez :
> *Because recorder requires SDK version ^3.14.0-68.0.dev, version solving failed.*

Vérifiez que votre fichier `pubspec.yaml` possède une contrainte compatible avec votre version de Flutter/Dart installée :
```yaml
environment:
  sdk: '>=3.3.0 <4.0.0'
```
Puis relancez :
```bash
flutter pub get
```

### 2. Erreur liée au NDK lors du build Android
> *NDK not configured or version mismatch*

Vérifiez dans Android Studio que la version NDK correspond bien à celle configurée dans `android/app/build.gradle.kts` :
```kotlin
ndkVersion = "29.0.14206865"
```
Si vous disposez d'une autre révision NDK 29 installée, ajustez le numéro de version en conséquence.

### 3. Permission Microphone
Sur Android, la permission `RECORD_AUDIO` est demandée dynamiquement avant le premier enregistrement via `audio_recorder_service.dart`. Assurez-vous d'accepter l'invite système pour autoriser la capture audio.

---

## 📄 Licence

Ce projet est sous licence privée ou sous les conditions définies par son propriétaire. Les dépendances open source intégrées respectent leurs licences respectives (Whisper.cpp, FFmpeg, PaddleOCR, NCNN).
