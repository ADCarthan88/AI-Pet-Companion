import 'dart:collection';

/// Simple in-memory badge/achievement tracking.
/// Badges are identified by string keys; each badge unlock triggers listeners.
class BadgeService {
  BadgeService._();
  static final BadgeService instance = BadgeService._();

  final Set<String> _earned = <String>{};
  final Map<String, int> _counters = <String, int>{};
  final List<void Function(String)> _listeners = [];

  UnmodifiableSetView<String> get earnedBadges => UnmodifiableSetView(_earned);
  int counter(String key) => _counters[key] ?? 0;

  void increment(String key, {int by = 1, int? threshold, String? badgeId}) {
    final newVal = (_counters[key] ?? 0) + by;
    _counters[key] = newVal;
    if (threshold != null && newVal >= threshold && badgeId != null) {
      award(badgeId);
    }
  }

  bool award(String badgeId) {
    if (_earned.contains(badgeId)) return false;
    _earned.add(badgeId);
    for (final l in _listeners) {
      l(badgeId);
    }
    return true;
  }

  void addListener(void Function(String) listener) => _listeners.add(listener);
  void removeListener(void Function(String) listener) => _listeners.remove(listener);

  void reset() {
    _earned.clear();
    _counters.clear();
  }
}
