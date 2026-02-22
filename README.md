# Morrolingo

<p align="center">
  <img src="https/raw.githubusercontent.com/Michiczi/morrolingo/main/assets/images/morrolingo-icon.png" alt="Morrolingo Logo" width="150"/>
</p>

<h2 align="center">A fully offline, Anki and Duolingo-inspired learning app based on flashcards.</h2>

> **Note:** Currently, the Morrolingo application is available only in Polish. An English version is planned for future releases.

---

## Table of Contents

- [Description](#description)
- [Key Features](#key-features)
- [Permissions Rationale](#permissions-rationale)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
  - [Android](#android)
  - [iOS (Sideloading)](#ios-sideloading)
- [Contributing & Feedback](#contributing--feedback)
- [License](#-license)

---

### 📖 Description

Morrolingo is a fully offline, privacy-focused language learning application inspired by the mechanics of Duolingo and the flexibility of Anki. It empowers you to build and study from your own custom vocabulary databases, turning the world around you into a personalized language lesson.

This app is designed for learners who want complete control over their study material without being tied to an internet connection.

### ✨ Key Features

- **Fully Offline:** Learn anytime, anywhere. All features are available without an internet connection.
- **Build Your Own Decks:** Create your own vocabulary sets from scratch to focus on what matters most to you.
- **Scan & Learn with OCR:** Use your device's camera to instantly scan text from books, menus, or signs. The app's Optical Character Recognition (OCR) digitizes the text, allowing you to create new flashcards on the fly.
- **Multiple Learning Modes:** Keep your study sessions engaging with various quiz formats:
  - Classic Flashcards
  - Multiple Choice Questions
  - Matching Games
- **Track Your Progress:** Stay motivated by tracking your daily learning streaks.
- **User-Provided Database:** Import your own pre-made vocabulary lists to get started quickly.

### 🔐 Permissions Rationale

Morrolingo requests certain permissions only to enable its core features. Your privacy is a priority, and the app functions entirely offline.

- **📷 Camera Access:** Required for the OCR "Scan & Learn" feature. This allows the app to capture images of text from the physical world so you can turn them into digital flashcards.
- **📁 Storage / File Access:** Required for importing your own custom question databases and for selecting images from your gallery for text recognition.

### 💻 Technology Stack

This application is built with **[Flutter](https://flutter.dev/)**, a cross-platform UI toolkit that allows it to deliver a native performance and feel on both Android and iOS from a single codebase.

---

## 📲 Installation

### ▶️ Android

1.  Navigate to the **[Releases](https://github.com/Michiczi/morrolingo/releases)** section of this repository.
2.  Download the latest `.apk` file (e.g., `morrolingo-v1.0.0.apk`).
3.  Open the downloaded file on your device. You may need to "Allow installation from unknown sources" in your phone's settings.
4.  Follow the on-screen prompts to complete the installation.

### 🍏 iOS (Sideloading)

Due to Apple's ecosystem restrictions, installing on iOS requires a sideloading process using **SideStore**, an alternative app marketplace.

The process has three main steps:

1.  **Setup Sideloading Tools:** Install `SideStore` on your iPhone using a computer.
2.  **Add App Source:** Add the Morrolingo repository to `SideStore`.
3.  **Configure Anti-Revoke:** Apply DNS settings to prevent the app's certificate from expiring.

#### Step 1: Install SideStore

To install SideStore, please follow the official documentation for your computer's operating system (Windows 10+, macOS, or Linux). The guide will walk you through the entire process.

➡️ **[Official SideStore Installation Guide](https://docs.sidestore.io/docs/installation/prerequisites)**

#### Step 2: Add the Morrolingo Repository to SideStore

Once `SideStore` is successfully installed on your iPhone, you need to add the source from which Morrolingo can be downloaded.

1.  Open `SideStore` on your iPhone.
2.  Navigate to the **"Sources"** tab.
3.  Add a new repository using the link below:
    ```
    https://raw.githubusercontent.com/Michiczi/morrolingo/main/morrolingo.json
    ```
4.  After the repository is added, Morrolingo will appear on the list. Tap to install it.

#### Step 3: Configure DNS (Anti-Revoke)

Apps sideloaded outside of the App Store have a certificate that is only valid for 7 days. To prevent it from expiring (requiring you to reinstall weekly), you must configure a special DNS profile.

1.  **Understand the Method:**
    - **Explanatory Article:** [TechyBuff - Anti Revoke Shortcut](https://techybuff.com/anti-revoke-shortcut/)

2.  **Download and Run the Shortcut:**
    - **Direct Shortcut Link:** [**AntiRevoke by iSpeedTest**](https://www.icloud.com/shortcuts/2253fa774c3442098be4baf1b03b8bb8)
    - Add this shortcut to your library and run it. The shortcut will automatically download and guide you through installing a DNS configuration profile that blocks Apple's servers from revoking the app certificate.

After completing these three steps, Morrolingo will be fully functional on your iOS device.

---

### 🤝 Contributing & Feedback

Have an idea for a new feature or found a bug? Feel free to open a new [Issue](https://github.com/Michiczi/morrolingo/issues) on GitHub.

---

### 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
