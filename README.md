# Solid State Physics MOOC Exam Quiz App ⚛️📚

A cross-platform Flutter mobile quiz and flashcard app designed for Solid State Physics MOOC preparation. Contains **111 questions** (Weeks 1 through 11) with formulas, diagrams, and options extracted directly from assignment materials.

---

## ✨ Features

- **3D Hardware-Accelerated Flashcard View**: Smooth realistic 3D card flip animation revealing accepted answers and reasoning.
- **Formula & Diagram Zoom**:
  - Multi-touch **pinch-to-zoom** (up to 5x magnification).
  - Overlay **`+` / `−`** zoom controls, percentage indicator, and quick reset.
  - **Fullscreen Lightbox** mode for inspecting intricate crystal structures and mathematical subscripts.
- **Interactive Option Testing**: Select options `(a)`, `(b)`, `(c)`, or `(d)` before flipping with instant visual feedback (green/red).
- **Comprehensive Question Bank**:
  - 111 total questions categorized across 11 weeks.
  - Study by individual week or test yourself with **"All 111 Questions"**.
- **Self-Assessment & Mastery Tracking**:
  - Mark questions as *"Mastered"* or *"Review Again"*.
  - Live progress bar and counters.
  - Grid bottom sheet to quickly jump to any question (Q1 to Q111).
  - Shuffle mode (`🔀`) for randomized practice.
- **Material 3 Design**: Fully responsive, with clean Light and Dark mode themes.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x or higher)
- Android Studio / Xcode / VS Code with Flutter extension

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/lakshya076/solid_state_mooc_quiz_app.git
   cd solid_state_mooc_quiz_app
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```
├── assets/
│   ├── data/
│   │   └── questions.json            # 111 questions metadata & answers
│   └── questions/
│       ├── week1/ ... week11/        # High-resolution question & option images
├── content/                          # Source assignment PDFs (Weeks 1 to 11)
├── lib/
│   ├── data/quiz_repository.dart     # Asynchronous asset & questions loader
│   ├── models/question.dart          # Typed data models
│   ├── screens/flashcard_screen.dart # Main quiz & flashcard screen
│   ├── widgets/
│   │   ├── flashcard_view.dart       # 3D interactive flip card
│   │   ├── zoomable_image.dart       # Pinch + button zoom controller
│   │   └── stats_bar.dart            # Progress and mastery tracking bar
│   └── main.dart                     # App entry point with Material 3 theming
└── scripts/
    ├── extract_questions.py          # PDF question and answer extraction tool
    └── verify_all.py                 # Asset integrity verification script
```
