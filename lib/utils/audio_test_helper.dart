// Simple test - let's try with a direct asset path test
// This will help us determine if the issue is format or path related

import 'package:flutter/services.dart';

class AudioTestHelper {
  static Future<bool> testAssetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      print('ASSET TEST: ✅ Found asset: $assetPath');
      return true;
    } catch (e) {
      print('ASSET TEST: ❌ Missing asset: $assetPath - $e');
      return false;
    }
  }
  
  static Future<void> runAssetTests() async {
    print('=== ASSET EXISTENCE TESTS ===');
    
    // Test the exact paths that are failing
    await testAssetExists('assets/sounds/dog/happy.mp3');
    await testAssetExists('assets/sounds/dog/sleep.mp3');
    await testAssetExists('assets/sounds/cat/happy_1.mp3');
    
    // Test root level files that should definitely exist
    await testAssetExists('assets/images/habitats/house_background.png');
    
    print('=== ASSET TESTS COMPLETE ===');
  }
}