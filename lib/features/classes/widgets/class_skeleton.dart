import 'package:flutter/material.dart';

class PulseSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const PulseSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  State<PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<PulseSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(
              0xFFE0E0E0,
            ).withValues(alpha: _animation.value), // --gray5
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class ClassSkeleton extends StatelessWidget {
  const ClassSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F092C4C), // 0.06 opacity
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Color(0x0A092C4C), // 0.04 opacity
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title & Students Skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PulseSkeleton(
                      width: 150,
                      height: 20,
                      margin: EdgeInsets.only(bottom: 8),
                    ),
                    PulseSkeleton(width: 100, height: 14),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PulseSkeleton(width: 48, height: 28, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 16),

          // Subjects Chips Skeleton
          const Row(
            children: [
              PulseSkeleton(width: 80, height: 24),
              SizedBox(width: 8),
              PulseSkeleton(width: 100, height: 24),
            ],
          ),
          const SizedBox(height: 20),

          // Attendance Skeleton
          const PulseSkeleton(
            width: double.infinity,
            height: 14,
            margin: EdgeInsets.only(bottom: 8),
          ),
          const PulseSkeleton(
            width: double.infinity,
            height: 6,
            borderRadius: 9999,
          ),
        ],
      ),
    );
  }
}
