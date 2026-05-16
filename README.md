# 🔥 Momentum — Smart Habit Tracker

Momentum is a modern productivity and habit tracking app built with Flutter and Firebase to help users stay consistent, motivated, and productive every day.

Unlike traditional to-do apps, Momentum combines streak systems, mood reflection, gamification, reminders, analytics, and AI-powered motivational feedback into one engaging experience.

Built for the Shortcut Asia Internship Challenge 2026.

---

# 🌐 Live Demo

🚀 Live App:
https://momentum-d7cf3.web.app

---

# ✨ Features

## 📌 Core Features

| Feature                    | Description                                                            |
| -------------------------- | ---------------------------------------------------------------------- |
| 🔐 Firebase Authentication | Secure email/password login and registration using Firebase Auth       |
| 📋 Habit Management        | Create, edit, delete, and organize habits with emoji and category tags |
| 🔥 Daily Streak System     | Automatic streak tracking with daily reset logic                       |
| 🔔 Smart Reminders         | Per-habit reminder times with local notifications                      |
| 📊 Analytics Dashboard     | Weekly charts, completion tracking, and productivity breakdowns        |
| 📅 Heatmap Calendar        | GitHub-style consistency heatmap visualization                         |
| 🔎 Search & Filters        | Filter habits by completion state and category                         |
| 🌙 Dark Mode               | Full light/dark theme support                                          |

---

## 🚀 Advanced Features

| Feature                              | Description                                                  |
| ------------------------------------ | ------------------------------------------------------------ |
| 🤖 AI Coach powered by Anthropic API | Personalized motivational insights and productivity feedback |
| 😄 Mood Reflection System            | Log moods and reflections after completing habits            |
| 🎮 XP & Leveling                     | Gain XP and level up through consistency                     |
| 🏆 Achievement System                | Unlock badges and milestones                                 |
| 🧊 Streak Freeze                     | Protect streaks during missed days                           |
| 📈 Weekly Challenges                 | Dynamic productivity challenges with XP rewards              |
| 🧠 Behavior Insights                 | AI-generated productivity summaries and encouragement        |
| 👤 Profile System                    | Username editing, profile image upload, password reset       |
| 📱 Mobile-First UI                   | Responsive iOS-inspired centered layout                      |
| 🎨 Premium UI/UX                     | Soft gradients, modern cards, emotional design language      |

---

# 🛠 Tech Stack

| Layer            | Technology                  |
| ---------------- | --------------------------- |
| Framework        | Flutter 3.x (Dart)          |
| State Management | Riverpod 2.x                |
| Backend          | Firebase Firestore          |
| Authentication   | Firebase Auth               |
| Hosting          | Firebase Hosting            |
| AI Integration   | Anthropic API (Claude)      |
| Networking       | http package                |
| Notifications    | flutter_local_notifications |
| Charts           | fl_chart                    |
| Heatmap          | flutter_heatmap_calendar    |
| Animations       | animate_do                  |

---

# 🏗 Architecture

```bash
lib/
├── core/
├── features/
│   ├── auth/
│   ├── habits/
│   ├── analytics/
│   ├── calendar/
│   ├── achievements/
│   ├── onboarding/
│   └── profile/
└── shared/
```

---

# 🚀 Running Locally

```bash
git clone https://github.com/nangsan17/momentum.git
cd momentum

flutter pub get
flutter run -d chrome
```

---

# 🌐 Deployment

Momentum is deployed using Firebase Hosting.

```bash
flutter build web
firebase deploy
```

Live URL:

https://momentum-d7cf3.web.app

---

# 📸 Screenshots

## 🏠 Home Dashboard

Dark-mode productivity dashboard with smart filtering, streak tracking, reminders, and responsive mobile UI.

<img src="screenshots/dark-home.png" width="250"/>

---

## 🤖 AI Productivity Insights

Anthropic-powered AI Coach with motivational feedback, behavior analysis, and productivity insights.

<img src="screenshots/ai-analytics.png" width="250"/>

---

## 📅 Habit Heatmap

GitHub-style consistency heatmap visualizing long-term productivity trends and daily habit completion.

<img src="screenshots/heatmap.png" width="250"/>

---

## 🔥 Habit Details & Streak System

Detailed habit progress view with streak freeze, reminder management, XP progression, and completion tracking.

<img src="screenshots/habit-details.png" width="250"/>

---

## 🏆 Achievement System

Gamified badge and achievement progression system designed to encourage long-term consistency.

<img src="screenshots/achievements.png" width="250"/>

---

## 👤 Profile & XP Progression

User profile management with XP leveling, dark mode, achievements, and account settings.

<img src="screenshots/profile-xp.png" width="250"/>

---

# 💡 Why I Built This

I wanted to create a productivity app that feels motivating instead of stressful.

Many habit apps focus only on task tracking, while Momentum focuses on emotional engagement, consistency psychology, and positive reinforcement through streaks, achievements, mood reflections, and AI-powered encouragement.

I also explored integrating real AI APIs to generate personalized motivational feedback based on user reflections and productivity progress.

---

# 🧠 Product Thinking

Momentum was designed not just as a task tracker, but as a behavioral support system.

The app focuses on:

* emotional engagement
* long-term motivation
* consistency psychology
* positive reinforcement
* gamification-driven productivity

Features such as AI coaching, XP systems, achievements, and streak freezes were designed to make consistency feel rewarding and sustainable.

---

# 📌 Future Improvements

* Native Android APK release
* Push notification sync
* Social/community habit sharing
* Shared focus sessions
* More advanced AI productivity coaching

---

# ❤️ Built For

Shortcut Asia Internship Challenge 2026
