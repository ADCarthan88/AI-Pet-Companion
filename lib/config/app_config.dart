class AppConfig {
  // Toggle for enabling test mode behaviors (infinite coins, etc.)
  static bool testMode = false;

  // Default starting coins for production users
  static const double defaultStartingCoins = 400.0;

  // Large number representing effectively infinite coins in test mode
  static const double testModeCoins = 9999999.0;
}
