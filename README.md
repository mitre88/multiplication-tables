# ✖️ Multiplication Masters

<div align="center">

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-purple.svg)

**A fun, colorful, and interactive iOS app to help children learn multiplication tables**

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Architecture](#-architecture) • [Localization](#-localization)

</div>

---

## 🌟 Features

### 📚 Learning Modes

- **Practice Mode**: Learn multiplication tables from 0 to 100
  - Sequential or randomized questions
  - Instant feedback on answers
  - Dynamic input system with custom number pad
  - Visual celebrations for correct answers

- **Challenge Mode**: Test your skills against the clock
  - Multiple difficulty levels (Easy, Normal, Hard)
  - Mixed questions from selected tables
  - Score tracking system
  - Time-based challenges

### 🎯 Progress Tracking

- **Comprehensive Statistics**
  - Total questions answered
  - Accuracy percentage
  - Best streak counter
  - Star rewards system

- **Achievement System**
  - First Steps: Answer 10 questions
  - Perfect Ten: 10 correct answers in a row
  - Master: Complete all basic tables
  - Speed Demon: Fast answers on 5 tables
  - Centurion: Reach table 100

- **Per-Table Analytics**
  - Individual table accuracy
  - Number of attempts
  - Mastery status
  - Average response time

### 🎨 Design & UX

- **Modern iOS Design**
  - Liquid glass effects (ultraThinMaterial)
  - Smooth gradient backgrounds
  - Fluid animations and transitions
  - Haptic feedback support

- **Kid-Friendly Interface**
  - Colorful and engaging visuals
  - Large, easy-to-read fonts
  - Intuitive navigation
  - Celebration animations with confetti and emojis

### 🌍 Multi-Language Support

- English 🇺🇸
- Spanish 🇪🇸
- French 🇫🇷

Full localization including UI text, achievements, and messages.

### ⚙️ Customization

- Sound effects toggle
- Background music toggle
- Haptic feedback control
- Difficulty settings
- Adjustable table range (up to 100)
- Progress reset option

---

## 📱 Screenshots

```
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   Splash Screen     │  │    Main Menu        │  │  Table Selector     │
│                     │  │                     │  │                     │
│       ✖️            │  │  📝 Practice        │  │  ┌───┐ ┌───┐ ┌───┐ │
│  Multiplication     │  │  🔥 Challenge       │  │  │ 0 │ │ 1 │ │ 2 │ │
│     Masters         │  │  📊 Progress        │  │  └───┘ └───┘ └───┘ │
│                     │  │  ⚙️  Settings       │  │  ┌───┐ ┌───┐ ┌───┐ │
│    ⭐ Stars: 42     │  │                     │  │  │ 3 │ │ 4 │ │ 5 │ │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘

┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   Practice View     │  │   Results View      │  │  Progress View      │
│                     │  │                     │  │                     │
│    Progress: 70%    │  │      🏆            │  │    📊 Statistics    │
│    ✓ 7/10          │  │                     │  │                     │
│                     │  │   Excellent!        │  │  Questions: 245     │
│     7 × 8          │  │                     │  │  Accuracy: 87%      │
│       =            │  │   ⭐⭐⭐          │  │  Streak: 12         │
│                     │  │                     │  │  Tables: 8/11       │
│     [  56  ]       │  │   Score: 8/10       │  │                     │
│                     │  │   Time: 02:34       │  │  🏆 Achievements   │
│  ┌───┬───┬───┐    │  │                     │  │  ⭐ First Steps    │
│  │ 1 │ 2 │ 3 │    │  │  🔄 Practice Again  │  │  🔥 Perfect Ten    │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

---

## 🛠 Installation

### Requirements

- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Build Instructions

1. Clone the repository:
```bash
git clone https://github.com/mitre88/multiplication-tables.git
cd multiplication-tables
```

2. Open the project in Xcode:
```bash
open MultiplicationTables.xcodeproj
# or
xed .
```

3. Select your target device or simulator

4. Build and run (⌘R)

---

## 🏗 Architecture

### Project Structure

```
MultiplicationTables/
├── MultiplicationTablesApp.swift      # App entry point
├── ContentView.swift                  # Root view controller
├── Models/
│   ├── UserProgress.swift            # User progress & achievements
│   ├── Question.swift                # Question generation & quiz session
│   └── AppSettings.swift             # App configuration
├── Views/
│   ├── SplashView.swift              # Launch screen with animations
│   ├── MainMenuView.swift            # Main navigation menu
│   ├── TableSelectorView.swift       # Table selection grid
│   ├── PracticeView.swift            # Practice mode with input
│   ├── ResultsView.swift             # Session results display
│   ├── ChallengeView.swift           # Challenge mode
│   ├── ProgressView.swift            # Statistics & achievements
│   └── SettingsView.swift            # App settings
├── Resources/
│   ├── Localizable.strings           # English localization
│   ├── es.lproj/
│   │   └── Localizable.strings       # Spanish localization
│   └── fr.lproj/
│       └── Localizable.strings       # French localization
└── Info.plist                        # App configuration
```

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **UserDefaults**: Local data persistence
- **LocalizationExtension**: Multi-language support

### Design Patterns

- **MVVM**: Model-View-ViewModel architecture
- **ObservableObject**: Reactive state management
- **Environment Objects**: Shared app state
- **Codable**: JSON serialization for data persistence

---

## 🌍 Localization

The app supports three languages with complete localization:

### Adding a New Language

1. Create a new `.lproj` folder:
```bash
mkdir MultiplicationTables/Resources/de.lproj
```

2. Copy and translate `Localizable.strings`:
```bash
cp MultiplicationTables/Resources/Localizable.strings \
   MultiplicationTables/Resources/de.lproj/
```

3. Add the language to `Info.plist`:
```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>es</string>
    <string>fr</string>
    <string>de</string>
</array>
```

4. Update `AppLanguage` enum in `MultiplicationTablesApp.swift`

---

## 🎨 Design System

### Color Palette

```swift
Primary Colors:
- Pink: #FF6B9D
- Purple: #C371F4
- Blue: #6E8EFB
- Teal: #4ECDC4
- Orange: #FFB347
- Yellow: #FFE66D
```

### Typography

- **Display**: System Rounded, Black weight
- **Headlines**: System Rounded, Bold weight
- **Body**: System Rounded, Medium weight
- **Sizes**: Dynamic based on context (14pt - 72pt)

### Effects

- **Liquid Glass**: `.ultraThinMaterial` with blur
- **Gradients**: Multi-color linear gradients
- **Shadows**: Subtle drop shadows with color tint
- **Animations**: Spring animations with custom damping

---

## 📊 Data Model

### UserProgress
- Completed tables tracking
- Per-table statistics
- Accuracy calculations
- Streak management
- Achievement system
- Star rewards

### Question
- Dynamic question generation
- Randomization support
- Time tracking
- Answer validation

### QuizSession
- Session state management
- Progress tracking
- Answer recording
- Results calculation

---

## 🎯 Features Roadmap

### Planned Features
- [ ] Sound effects and background music
- [ ] More achievement types
- [ ] Leaderboard system
- [ ] Parent dashboard
- [ ] Custom practice ranges
- [ ] Division mode
- [ ] Offline mode improvements
- [ ] iPad optimization
- [ ] Dark mode support

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Guidelines

1. Follow Swift naming conventions
2. Use SwiftUI best practices
3. Maintain existing code style
4. Add localization for new strings
5. Test on multiple iOS versions
6. Document complex logic

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Author

**Dr. Alex Mitre**
- GitHub: [@mitre88](https://github.com/mitre88)
- Email: bedr10_capacitacion@hotmail.com

---

## 🙏 Acknowledgments

- SwiftUI community for inspiration
- Apple Human Interface Guidelines
- Kids and educators who provided feedback

---

<div align="center">

**Made with ❤️ for children learning mathematics**

⭐ Star this repo if you find it helpful!

</div>
