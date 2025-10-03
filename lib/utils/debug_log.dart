import 'package:flutter/foundation.dart';

void debugLog(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[DEBUG] $message');
  }
}