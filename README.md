# Echo Music (iOS)

An open-source, ad-free music streaming client for iOS built with **SwiftUI**, **AVFoundation**, and **Swift Package Manager (SwiftPM)**, compiled cross-platform using [xtool](https://github.com/xtool-org/xtool).

![Platform: iOS 17+](https://img.shields.io/badge/Platform-iOS%2017%2B-blue)
![Swift: 6.0+](https://img.shields.io/badge/Swift-6.0%2B-orange)
![Toolchain: xtool](https://img.shields.io/badge/Toolchain-xtool-green)

---

## ✨ Features

- 🎧 **Native Audio Engine:** High-performance audio streaming via `AVPlayer`.
- 🌙 **Echo Music Dark Theme:** Elegant dark-mode UI with fluid animations.
- 📱 **Lock Screen & Control Center Integration:** Native `MPNowPlayingInfoCenter` and `MPRemoteCommandCenter` controls (Play, Pause, Skip, Scrub).
- 🔄 **Background Audio Playback:** Continuous music streaming when locked or multitasking.
- 🔍 **Live Music Search:** Instant music search with 600x600 high-res album artwork.
- 🚀 **Quick Picks & Mood Stations:** Chill, Workout, Focus, Lo-Fi, Electronic, and Party stations.
- ❤️ **Favorites & Library:** Save your favorite tracks and browse playback history.
- 📋 **Interactive Queue:** Dynamic Up-Next queue sheet with shuffle and repeat modes.

---

## 🛠️ Building with xtool

This project uses standard SwiftPM without requiring heavy Xcode project files.

### 1. Build .app Bundle
```bash
xtool dev build
```

### 2. Package into .ipa
```bash
xtool dev build --ipa
```

### 3. Deploy to Connected Device
```bash
xtool dev
```

---

## 📄 License

GPL-3.0 License
