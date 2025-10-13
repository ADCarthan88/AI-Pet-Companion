import 'package:flutter/material.dart';
import '../services/badge_service.dart';

/// Overlay widget that listens for new badges and displays a transient toast-like banner.
class BadgeOverlay extends StatefulWidget {
  const BadgeOverlay({super.key, this.child});
  final Widget? child;

  @override
  State<BadgeOverlay> createState() => _BadgeOverlayState();
}

class _BadgeOverlayState extends State<BadgeOverlay>
    with SingleTickerProviderStateMixin {
  String? _latestBadge;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    BadgeService.instance.addListener(_onBadge);
  }

  void _onBadge(String id) {
    setState(() => _latestBadge = id);
    _controller.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    BadgeService.instance.removeListener(_onBadge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (_latestBadge != null)
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _controller,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          'Badge Earned: $_latestBadge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
