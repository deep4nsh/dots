import 'dart:math';

class DumpPrompts {
  static const List<String> _prompts = [
    "Scream into the void. It listens.",
    "Your brain is a browser with 50 tabs open. Close one here.",
    "What's the weirdest thing you saw today?",
    "Plotting world domination? Start here.",
    "If thoughts were heavy, how much would this weigh?",
    "Confess a sin. No one is watching.",
    "Spill the tea. (Digital tea doesn't stain).",
    "Write it down before you forget it like that dream.",
    "The universe is waiting for your signal.",
    "Blink twice if you need a coffee.",
    "What would you tell your 5-year-old self?",
    "Unload your RAM.",
    "Everything starts as a dot. Even this thought.",
    "Don't let this thought escape into the ether.",
    "Type faster than your internal critic speaks.",
    "A safe space for your unsafe ideas.",
    "Chaos is just unorganized brilliance. Organize it.",
    "Your future biographer will thank you for this.",
    "Whatever it is, it's better out than in.",
    "Make this space your own personal galaxy.",
  ];

  static String getRandom() {
    return _prompts[Random().nextInt(_prompts.length)];
  }
}
