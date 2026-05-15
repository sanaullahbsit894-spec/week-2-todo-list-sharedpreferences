# TaskFlow

A clean, professional Flutter app built for Week 2 of the Flutter learning curriculum — covering state management and persistent local storage.

---

## Features

### Counter
- Increment and decrement a counter using `setState`
- Value persists across app restarts via `SharedPreferences`
- Animated number display with haptic feedback
- Reset button to clear back to zero

### To-Do List
- Add tasks with a clean input field
- Tasks displayed in a scrollable `ListView`
- Swipe left on any task to delete it
- Tap a task to mark it done (with strikethrough + checkbox animation)
- Progress bar showing completion ratio
- "Clear done" button to bulk-remove completed tasks
- All tasks saved and restored using `SharedPreferences`

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3.x |
| State | `setState` (built-in) |
| Storage | `shared_preferences` |
| UI extras | `flutter_slidable`, `google_fonts` |

---

## Project Structure

```
lib/
├── main.dart                  # Entry point
├── app.dart                   # MaterialApp + theme
├── models/
│   └── task.dart              # Task data model
├── services/
│   └── storage_service.dart   # SharedPreferences wrapper
└── screens/
    ├── home_screen.dart        # Bottom nav scaffold
    ├── tasks_screen.dart       # To-do list UI
    └── counter_screen.dart     # Counter UI
```

---

## Getting Started

```bash
git clone https://github.com/yourusername/taskflow.git
cd taskflow
flutter pub get
flutter run
```

Requires Flutter 3.0+ and Dart 3.0+.

---

## Learning Objectives Covered

- **State Management** — `setState` used throughout to reactively update UI on user interaction
- **Persistent Storage** — `SharedPreferences` saves both counter value and task list as JSON; data survives app restarts
- **ListView** — Tasks rendered in a scrollable list with swipe-to-delete via `Slidable`
