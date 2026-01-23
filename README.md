# dots - A Minimalist Thought Capture App

**dots** is a sleek, minimalist Flutter application designed to help users capture their thoughts, ideas, and reflections instantly. By leveraging AI-driven insights and a clean user interface, **dots** transforms raw brain dumps into meaningful patterns and actionable insights.

## 🚀 Features

-   **Thought Dumping:** Quickly capture text, images, and voice notes without friction.
-   **AI Insights:** Powered by Google Gemini to analyze your "dots" and provide daily summaries, weekly reflections, and deep thematic insights.
-   **Visual Analytics:** Track your mental trends and thought patterns over time with interactive charts.
-   **Secure Cloud Sync:** Real-time data synchronization across devices using Supabase.
-   **Dark Mode by Default:** A focused, distraction-free environment for your thoughts.
-   **Fluid Animations:** Smooth transitions and micro-interactions for a premium feel.

## 🛠 Tech Stack

-   **Frontend:** [Flutter](https://flutter.dev) (Dart)
-   **State Management:** [Riverpod](https://riverpod.dev)
-   **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
-   **Backend:** [Supabase](https://supabase.com) (Authentication, Database, Storage)
-   **AI Engine:** [Google Generative AI (Gemini)](https://ai.google.dev/)
-   **Animations:** [Flutter Animate](https://pub.dev/packages/flutter_animate) & [Animations package](https://pub.dev/packages/animations)
-   **Charts:** [FL Chart](https://pub.dev/packages/fl_chart)

## 📦 Getting Started

### Prerequisites

-   Flutter SDK (^3.10.4)
-   Dart SDK
-   A Supabase Project
-   A Google AI (Gemini) API Key

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/dots.git
    cd dots
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Setup Environment Variables:**
    Create a `.env` file in the root directory and add your credentials:
    ```env
    SUPABASE_URL=your_supabase_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    GOOGLE_API_KEY=your_gemini_api_key
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```

## 📂 Project Structure

```text
lib/
├── core/               # Shared logic, themes, and service initializations
│   ├── services/       # AI and Supabase service integrations
│   └── theme/          # App-wide UI styling and colors
├── features/           # Feature-based modular architecture
│   ├── auth/           # Login and Registration flows
│   ├── dump/           # Core note-taking / thought capture feature
│   ├── home/           # Main dashboard and navigation
│   ├── insights/       # AI analysis and data visualization
│   ├── settings/       # User profile and app configurations
│   └── splash/         # Initial loading experience
└── main.dart           # App entry point and router configuration
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git checkout origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
Built with ❤️ using Flutter.
