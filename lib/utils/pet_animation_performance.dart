

/// Performance monitoring utility for optimizing pet animations
class PetAnimationPerformanceMonitor {
  static final PetAnimationPerformanceMonitor _instance = 
      PetAnimationPerformanceMonitor._internal();
  
  factory PetAnimationPerformanceMonitor() => _instance;
  
  PetAnimationPerformanceMonitor._internal();

  // Performance tracking
  final List<int> _frameTimes = [];
  int _frameCount = 0;
  int _lastFrameTime = 0;
  double _averageFPS = 0.0;
  
  // Animation optimization settings
  static const int _maxFrameHistory = 60; // Track last 60 frames
  static const double _targetFPS = 60.0;
  static const double _minAcceptableFPS = 30.0;
  
  /// Record a frame for performance tracking
  void recordFrame() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    if (_lastFrameTime > 0) {
      final frameTime = currentTime - _lastFrameTime;
      _frameTimes.add(frameTime);
      
      // Keep only recent frame history
      if (_frameTimes.length > _maxFrameHistory) {
        _frameTimes.removeAt(0);
      }
      
      // Calculate average FPS
      if (_frameTimes.isNotEmpty) {
        final averageFrameTime = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
        _averageFPS = 1000.0 / averageFrameTime; // Convert ms to FPS
      }
    }
    
    _lastFrameTime = currentTime;
    _frameCount++;
  }
  
  /// Get current average FPS
  double get averageFPS => _averageFPS;
  
  /// Check if performance is acceptable
  bool get isPerformanceGood => _averageFPS >= _minAcceptableFPS;
  
  /// Get recommended animation quality based on performance
  AnimationQuality get recommendedQuality {
    if (_averageFPS >= _targetFPS) {
      return AnimationQuality.high;
    } else if (_averageFPS >= _minAcceptableFPS) {
      return AnimationQuality.medium;
    } else {
      return AnimationQuality.low;
    }
  }
  
  /// Get optimized frame duration based on performance
  Duration get optimizedFrameDuration {
    switch (recommendedQuality) {
      case AnimationQuality.high:
        return const Duration(milliseconds: 16); // 60 FPS
      case AnimationQuality.medium:
        return const Duration(milliseconds: 33); // 30 FPS
      case AnimationQuality.low:
        return const Duration(milliseconds: 50); // 20 FPS
    }
  }
  
  /// Reset performance tracking
  void reset() {
    _frameTimes.clear();
    _frameCount = 0;
    _lastFrameTime = 0;
    _averageFPS = 0.0;
  }
  
  /// Get performance statistics
  Map<String, dynamic> getStats() {
    return {
      'averageFPS': _averageFPS,
      'frameCount': _frameCount,
      'quality': recommendedQuality.toString(),
      'isPerformanceGood': isPerformanceGood,
      'frameHistoryLength': _frameTimes.length,
    };
  }
}

/// Animation quality levels for performance optimization
enum AnimationQuality {
  high,   // Full quality, 60 FPS, all effects
  medium, // Reduced quality, 30 FPS, essential effects only
  low,    // Minimal quality, 20 FPS, basic animations only
}

/// Mixin for widgets that need performance-optimized animations
mixin PetAnimationOptimization {
  final PetAnimationPerformanceMonitor _monitor = PetAnimationPerformanceMonitor();
  
  /// Record frame for performance tracking
  void recordAnimationFrame() {
    _monitor.recordFrame();
  }
  
  /// Get optimized frame duration
  Duration get optimizedFrameDuration => _monitor.optimizedFrameDuration;
  
  /// Get current animation quality
  AnimationQuality get animationQuality => _monitor.recommendedQuality;
  
  /// Check if high quality animations should be used
  bool get shouldUseHighQualityAnimations => 
      _monitor.recommendedQuality == AnimationQuality.high;
  
  /// Get walking animation step size based on performance
  double getOptimizedWalkingStep(double baseStep) {
    switch (_monitor.recommendedQuality) {
      case AnimationQuality.high:
        return baseStep;
      case AnimationQuality.medium:
        return baseStep * 1.5; // Larger steps for lower frame rate
      case AnimationQuality.low:
        return baseStep * 2.0; // Even larger steps
    }
  }
}