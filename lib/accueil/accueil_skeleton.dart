import 'package:flutter/material.dart';

class AccueilSkeleton extends StatefulWidget {
  const AccueilSkeleton({super.key});

  @override
  State<AccueilSkeleton> createState() => _AccueilSkeletonState();
}

class _AccueilSkeletonState extends State<AccueilSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bone({double? width, double height = 14, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _bone(width: 48, height: 48, radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bone(width: 70, height: 11),
                        const SizedBox(height: 7),
                        _bone(width: 150, height: 16),
                      ],
                    ),
                  ),
                  _bone(width: 40, height: 40, radius: 20),
                ],
              ),
              const SizedBox(height: 32),
              // Date title
              _bone(width: 170, height: 20),
              const SizedBox(height: 18),
              // 3 séance card skeletons
              for (int i = 0; i < 3; i++) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 88,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(width: 4, color: const Color(0xFFE0E0E0)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    _bone(width: 80, height: 12),
                                    const Spacer(),
                                    _bone(width: 64, height: 22, radius: 6),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _bone(width: 130, height: 14),
                                const SizedBox(height: 6),
                                _bone(width: 100, height: 11),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(height: 10),
              ],
              const SizedBox(height: 28),
              // "Mes classes" title
              _bone(width: 120, height: 20),
              const SizedBox(height: 16),
              // Class card skeletons
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      Container(
                        width: 130,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      if (i < 2) const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
