# 🤖 AI Kids Academy

An educational Flutter app for children aged 5–7 that teaches the basics of Artificial Intelligence through fun, interactive lessons with mascot robot **Beep / Бип / ביפ**.

---

## Features

- **12 complete lessons** covering AI fundamentals for young children
- **3 languages**: English 🇬🇧, Russian 🇷🇺, Hebrew 🇮🇱
- **Full RTL support** for Hebrew
- **Language selection** on first launch
- **Interactive quiz** after each lesson
- **Star reward system** and progress tracking
- **Local progress storage** (SharedPreferences — no internet required)
- **Parent info screen** with safety information
- **Child-friendly UI** — big buttons, rounded cards, animations
- **No ads, no login, no payments, no data collection**

---

## Screens

| Screen | Description |
|--------|-------------|
| Splash | Animated intro with mascot |
| Language Selection | Choose EN / RU / HE on first launch |
| Welcome | Mascot greeting |
| Lesson Map | 12 lesson cards with lock/unlock progression |
| Lesson | Multi-page lesson content with mascot commentary |
| Quiz | Multiple-choice questions with instant feedback |
| Reward | Star award and score summary |
| Progress | Stats, lesson list, and reset option |
| Parent Info | Safety information and language switcher |

---

## Lessons

1. 🤖 What is AI?
2. 💬 How to Ask Clearly
3. ✅ Good Prompt vs Bad Prompt
4. 🖼️ Describing Images
5. 📖 Asking for Stories
6. 📚 Safe Homework Help
7. 🛡️ Online Safety
8. 🔍 Is It True? (Fact Checking)
9. 💡 Creative Ideas
10. 🎤 Voice Commands
11. 📷 Taking Useful Photos
12. 🏆 Final Mission

---

## Architecture

```
lib/
├── main.dart                  # Entry point, providers setup
├── app.dart                   # MaterialApp with theming & localization
├── constants/
│   ├── app_colors.dart        # Color palette and gradients
│   └── app_strings.dart       # All UI strings in 3 languages
├── models/
│   └── lesson.dart            # Lesson, ContentBlock, QuizQuestion
├── services/
│   └── lesson_service.dart    # JSON loader with caching
├── providers/
│   ├── language_provider.dart # Language state (persisted)
│   └── progress_provider.dart # Progress state (persisted)
├── screens/
│   ├── splash_screen.dart
│   ├── language_selection_screen.dart
│   ├── welcome_screen.dart
│   ├── lesson_map_screen.dart
│   ├── lesson_screen.dart
│   ├── quiz_screen.dart
│   ├── reward_screen.dart
│   ├── progress_screen.dart
│   └── parent_info_screen.dart
└── widgets/
    ├── mascot_widget.dart     # Animated floating robot mascot
    └── lesson_card.dart       # Lesson grid card with lock states

assets/data/
├── lessons_en.json            # 12 lessons in English
├── lessons_ru.json            # 12 lessons in Russian
└── lessons_he.json            # 12 lessons in Hebrew
```

---

## Tech Stack

- **Flutter** 3.22+
- **Provider** — state management
- **SharedPreferences** — local progress storage
- **Google Fonts** (Nunito) — child-friendly typography
- **Flutter Localizations** — RTL support for Hebrew

---

## GitHub Actions

`.github/workflows/build-apk.yml` automatically:

1. Installs Flutter 3.22
2. Runs `flutter pub get`
3. Runs `flutter test`
4. Builds a **debug APK** for Android arm64
5. Uploads the APK as a workflow artifact (14 day retention)

**Trigger:** Push or PR to `main` / `master`, or manual dispatch.

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run tests
flutter test

# Build debug APK
flutter build apk --debug --target-platform android-arm64
```

---

## Lesson JSON Format

```json
{
  "lessons": [
    {
      "id": "lesson_1",
      "title": "What is AI?",
      "description": "Discover what AI is!",
      "emoji": "🤖",
      "content": [
        { "type": "text", "text": "AI stands for..." },
        { "type": "mascot", "text": "Hi! I'm Beep..." }
      ],
      "quiz": [
        {
          "question": "What does AI stand for?",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correct": 1
        }
      ]
    }
  ]
}
```

**Content block types:**
- `text` — regular content card
- `mascot` — speech bubble from robot mascot

---

## Future Roadmap

- [ ] Remote lesson updates (fetch from URL, fallback to local)
- [ ] Audio narration for each lesson
- [ ] Animated Lottie mascot
- [ ] Parent dashboard with detailed analytics
- [ ] Additional languages
- [ ] Release APK signing workflow
- [ ] iOS support

---

## Privacy & Safety

- No internet required (offline-first)
- No user accounts or login
- No analytics or tracking
- No ads
- No in-app purchases
- All data stored locally on device only
