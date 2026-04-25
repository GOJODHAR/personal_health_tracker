# Personal Health Tracker - Viva Preparation Guide

This guide is designed to help you prepare for your viva (verbal presentation/examination) for the **Personal Health Tracker** project. It covers the core aspects of your project, the technology stack, architecture, and potential questions the examiner might ask.

## 1. Project Overview

> **Tip:** Start your presentation with a brief, impactful summary.

**What is it?**
The Personal Health Tracker is a comprehensive, cross-platform mobile application built to help users seamlessly monitor their daily health metrics. It is designed to track weight, steps, water intake, sleep hours, and workouts.

**Why was it built?**
To solve the problem of fragmented health data by bringing daily metrics and active workouts into a single, unified view, providing users with a "Health Score", streak motivation, and AI-driven smart insights based on their progress.

## 2. Technology Stack

You should be ready to defend *why* you chose these technologies:

*   **Frontend**: Flutter (Dart)
    *   *Why?* Single codebase for multiple platforms (Android/iOS), incredibly fast UI rendering engine, rich set of pre-built widgets.
*   **Backend & Database**: Firebase (Authentication & Cloud Firestore)
    *   *Why?* Real-time database capabilities, offline support out-of-the-box, seamless integration with Flutter, secure authentication.
*   **State Management**: Provider
    *   *Why?* It is the recommended, straightforward way to manage app state in Flutter without over-complicating architecture (unlike Redux or BLoC which might be overkill for this app size).
*   **Key Packages**: 
    *   `fl_chart`: For rendering progress graphs.
    *   `flutter_local_notifications` & `timezone`: For daily reminders.
    *   `google_fonts`: For modern typography (Poppins).

## 3. Architecture & Data Flow

Your app loosely follows an **MVVM (Model-View-ViewModel)** or a **Service-Provider** architecture.

1.  **Models (`lib/models/`)**: Define the data structures (`UserModel`, `HealthLog`, `GoalModel`).
2.  **Services (`lib/services/`)**: Handle external API or database calls (`FirestoreService` for DB, `AuthService` for auth, `NotificationService` for local push notifications).
3.  **Providers (`lib/providers/`)**: Act as ViewModels. They hold the application state (`HealthProvider`, `GoalProvider`, `AuthProvider`). They call the Services and update the UI when data changes using `notifyListeners()`.
4.  **Screens (`lib/screens/`)**: The Views. They listen to the Providers and rebuild when the state changes.

## 4. Key Features to Highlight

When demonstrating the app, make sure to show these off:

*   **Dynamic Health Score & BMI**: The dashboard calculates a health score out of 100 based on how close the user is to their daily goals. The BMI is calculated automatically from the user's height and logged weight.
*   **Unified Health Logging**: Instead of separating workouts and daily stats, they are merged into a single `HealthLog` model per day, simplifying the backend and the user experience.
*   **Smart Insights**: Shows dynamic motivation based on streaks (e.g., "🔥 Amazing consistency! 7 day streak!").
*   **Responsive Theming**: Fully supports both Light and Dark modes with a clean, modern wellness UI.
*   **Graphs and History**: The `HistoryScreen` uses `fl_chart` to visualize past health data.

## 5. Potential Viva Questions & Answers

> **Note:** Practice these questions verbally before your presentation.

**Q: Why did you choose Flutter over native Android (Java/Kotlin) or React Native?**
*Answer:* I chose Flutter because it allows me to compile natively compiled applications for mobile from a single codebase. Its UI rendering engine ensures smooth 60fps animations. Compared to React Native, it doesn't use a JavaScript bridge, which improves performance.

**Q: How are you managing state in this application?**
*Answer:* I am using `Provider`. It is a wrapper around `InheritedWidget` that makes state management scalable and maintainable. For example, my `HealthProvider` fetches logs from `FirestoreService`, stores them in a list, and calls `notifyListeners()`, which then seamlessly updates the `DashboardScreen`.

**Q: Could you explain your database schema in Firebase?**
*Answer:* I use Cloud Firestore, a NoSQL document database. There are three main collections:
1. `users`: Stores profile data like name and height, which is used for BMI calculation.
2. `health_logs`: Stores daily entries like steps, water, sleep, weight, and workout duration/calories.
3. `goals`: Stores the user's target weight, daily water goal, step goal, etc.

**Q: How did you handle offline capabilities?**
*Answer:* Cloud Firestore provides offline persistence by default. If the user logs water intake without an internet connection, it’s saved locally and automatically synced to the cloud once the connection is restored.

**Q: What was the biggest challenge you faced during development?**
*Answer:* *(Provide your real experience)* Merging the workout data into the daily health logs was challenging. I initially had two separate collections, but I realized it was better to have one unified `HealthLog` per day. I had to refactor the models and UI to support multiple workout types in a single daily document.

**Q: How does the app calculate the "Health Score"?**
*Answer:* It takes four metrics (water, steps, sleep, and weight). It calculates the percentage completion for water, steps, and sleep against the user's goals. For weight, it calculates how close the current weight is to the target weight (using absolute difference). It averages these four percentages to give a score out of 100.

## 6. Pro-Tips for the Presentation

*   **Setup early**: Ensure your emulator or physical device is fully set up and the app is running *before* the viva starts.
*   **Show, don't just tell**: When talking about the Health Score or Workout addition, actually add a log and watch the UI dynamically update.
*   **Acknowledge limitations**: If asked what you would improve, mention things like "Adding Social Features (Leaderboards)," "Integration with Apple Health API/Google Fit API," or "More advanced AI-based diet recommendations." Examiners love it when developers know how to scale their own projects.
