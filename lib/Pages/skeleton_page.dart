import 'package:flutter/material.dart';

void main() {
  runApp(const SkeletonApp());
}

class SkeletonApp extends StatelessWidget {
  const SkeletonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SkeletonPage(),
    );
  }
}

class SkeletonPage extends StatelessWidget {
  const SkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(44),
            border: Border.all(color: const Color(0xFF1D1D1D), width: 8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 80,
                offset: Offset(0, 40),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header skeleton
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        SkeletonBox(width: 48, height: 48, radius: 24),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 80, height: 14),
                            SizedBox(height: 6),
                            SkeletonBox(width: 120, height: 20),
                          ],
                        ),
                      ],
                    ),
                    SkeletonBox(width: 40, height: 40, radius: 20),
                  ],
                ),
              ),

              // Justif card skeleton
              const Padding(
                padding: EdgeInsets.all(16),
                child: SkeletonBox(width: double.infinity, height: 80, radius: 16),
              ),

              // Section "Aujourd'hui"
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 120, height: 20),
                      SizedBox(height: 12),
                      SkeletonBox(width: double.infinity, height: 80, radius: 16),
                      SizedBox(height: 12),
                      SkeletonBox(width: double.infinity, height: 80, radius: 16),
                      SizedBox(height: 12),
                      SkeletonBox(width: double.infinity, height: 80, radius: 16),

                      SizedBox(height: 24),
                      SkeletonBox(width: 100, height: 20),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          SkeletonBox(width: 140, height: 100, radius: 16),
                          SizedBox(width: 12),
                          SkeletonBox(width: 140, height: 100, radius: 16),
                          SizedBox(width: 12),
                          SkeletonBox(width: 140, height: 100, radius: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation
              BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendrier"),
                  BottomNavigationBarItem(icon: Icon(Icons.book), label: "Mes cours"),
                  BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Ressources"),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
                ],
                currentIndex: 0,
                selectedItemColor: const Color(0xFF092C4C),
                unselectedItemColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget Skeleton animé
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(_controller);
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
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
