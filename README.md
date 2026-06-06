<div align="center">

# 🎬 Media Downloader

**A sleek, modern Flutter-based desktop application for downloading videos and audio from various platforms using the power of `yt-dlp`.**

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)](https://www.apple.com/macos)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)

</div>

---

## 📖 Overview

**Media Downloader** is a cross-platform desktop application designed to provide a seamless, user-friendly interface over `yt-dlp`. Built entirely in Flutter, it focuses on performance, modern aesthetics, and ease of use. Whether you need to download a quick audio track or a high-resolution video playlist, Media Downloader streamlines the process without requiring terminal commands.

## ✨ Key Features

- **🚀 Universal Platform Support:** Downloads from YouTube, Vimeo, Twitter, Reddit, and hundreds of other websites supported by `yt-dlp`.
- **🎨 Beautiful Modern UI:** A fully responsive, sleek desktop interface crafted with Flutter and smooth animations.
- **🎧 Audio & Video Extraction:** Easily choose between downloading full videos or extracting audio only.
- **📁 Drag & Drop Support:** Drop links directly into the app for lightning-fast processing.
- **📂 Custom Save Locations:** Easily configure and remember your preferred download directories.
- **📊 Real-time Progress Tracking:** Monitor your download speeds, progress, and history directly within the app.

## 🛠️ Technology Stack

The project follows **Clean Architecture** principles (`core`, `data`, `domain`, `presentation`), ensuring scalability and maintainability.

- **Framework:** [Flutter](https://flutter.dev/) (Desktop)
- **State Management:** [Riverpod](https://riverpod.dev/) (`flutter_riverpod`, `riverpod_generator`)
- **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
- **Routing:** [GoRouter](https://pub.dev/packages/go_router)
- **Networking:** [Dio](https://pub.dev/packages/dio)
- **Desktop Window Management:** [window_manager](https://pub.dev/packages/window_manager)
- **Drag & Drop:** [desktop_drop](https://pub.dev/packages/desktop_drop)

---

## 🚀 Getting Started

### Prerequisites

To build and run this application locally, you will need the following installed:

1. **Flutter SDK** (`^3.5.0` or higher): [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **FFmpeg** (Highly Recommended): Required by `yt-dlp` for merging video and audio streams, or extracting audio. 
   - *macOS:* `brew install ffmpeg`
   - *Windows:* `winget install ffmpeg`
3. **yt-dlp**: The app utilizes the `yt-dlp` binary. Ensure it is accessible or bundled according to the app's internal logic.

### Installation & Build

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/media_downloader.git
   cd media_downloader
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (for Riverpod, Freezed, JSON Serializable):**
   ```bash
   dart run build_runner build -d
   ```

4. **Run the app:**
   ```bash
   flutter run -d macos # or windows/linux depending on your OS
   ```

---

## 🏗️ Architecture Overview

The codebase is strictly separated into layers to ensure high testability and separation of concerns:

- **`lib/core/`**: App-wide constants, themes, error handling, and utilities.
- **`lib/data/`**: Models, API services, local storage (`shared_preferences`), and `yt-dlp` binary integration.
- **`lib/domain/`**: Business logic, entities, and repository interfaces.
- **`lib/presentation/`**: UI components, screens, and Riverpod state controllers.

---

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 👨‍💻 Developed By

This project was developed by **Harith Bashar** with the assistance of AI.

**Connect with me:**
- 📧 Email: [harithbashar@gmail.com](mailto:harithbashar@gmail.com)
- 💼 LinkedIn: [Harith Bashar](https://www.linkedin.com/in/harithbashar/)
- 🐙 GitHub: [@HarithBashar](https://github.com/HarithBashar)
- 📸 Instagram: [@harith.bashar](https://www.instagram.com/harith.bashar/)

---

## 📄 License

This project is open-source and available under the **MIT License**.

> [!NOTE]
> This application acts as a GUI wrapper around `yt-dlp`. Users are responsible for adhering to the terms of service of the platforms they are downloading from, as well as applicable copyright laws.
# Media-Downloader
