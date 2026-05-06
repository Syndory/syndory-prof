import 'package:flutter/material.dart';
import '../classes/models/models.dart';
import '../classes/effectifs_screen.dart';

class PreSessionScreen extends StatefulWidget {
  final ClassModel classInfo;

  const PreSessionScreen({super.key, required this.classInfo});

  @override
  State<PreSessionScreen> createState() => _PreSessionScreenState();
}

class _PreSessionScreenState extends State<PreSessionScreen> {
  int _markingWindow = 10; // minutes

  void _incrementWindow() {
    setState(() {
      _markingWindow += 5;
    });
  }

  void _decrementWindow() {
    if (_markingWindow > 5) {
      setState(() {
        _markingWindow -= 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF092C4C);
    const Color primaryDim = Color(0xFFE8EFF5);
    const Color secondary = Color(0xFFF2994A);
    const Color secondaryDim = Color(0xFFFEF3E7);
    const Color success = Color(0xFF27AE60);
    const Color successDim = Color(0xFFE8F8EF);
    const Color info = Color(0xFF2F80ED);
    const Color infoDim = Color(0xFFEBF3FE);
    const Color bg = Color(0xFFF5F7FA);
    const Color gray2 = Color(0xFF4F4F4F);
    const Color gray3 = Color(0xFF828282);
    const Color gray5 = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background Gradient effect (subtle)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryDim.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _CircularButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              widget.classInfo.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: primary,
                                letterSpacing: -0.18,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      _CircularButton(
                        icon: Icons.notifications_none,
                        onPressed: () {},
                        iconColor: gray2,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        // Card Details
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14092C4C),
                                offset: Offset(0, 2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.book_outlined,
                                iconBg: primaryDim,
                                iconColor: primary,
                                title: 'Cours Magistral',
                                subtitle: '${widget.classInfo.filiere} • Filière A',
                              ),
                              const _Divider(),
                              const _DetailRow(
                                icon: Icons.location_on_outlined,
                                iconBg: secondaryDim,
                                iconColor: secondary,
                                title: 'Amphi B204',
                                subtitle: 'Bâtiment Sciences',
                              ),
                              const _Divider(),
                              const _DetailRow(
                                icon: Icons.access_time,
                                iconBg: infoDim,
                                iconColor: info,
                                title: '10:15 — 12:15',
                                subtitle: 'Mardi 28 Avril 2026',
                              ),
                              const _Divider(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EffectifsScreen(classInfo: widget.classInfo),
                                    ),
                                  );
                                },
                                child: _DetailRow(
                                  icon: Icons.people_outline,
                                  iconBg: successDim,
                                  iconColor: success,
                                  title: '${widget.classInfo.studentCount} étudiants inscrits',
                                  subtitle: 'Liste à jour',
                                  showArrow: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Geo Section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14092C4C),
                                offset: Offset(0, 2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Géolocalisation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: primary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Rayon : 80 m',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: gray3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: successDim,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check, color: success, size: 24),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vous êtes dans la salle ✓',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: success,
                                          ),
                                        ),
                                        Text(
                                          'Position validée à l\'instant',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: success,
                                            opacity: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Config Section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14092C4C),
                                offset: Offset(0, 2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fenêtre de marquage',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Temps accordé aux étudiants pour scanner le QR Code et marquer leur présence.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: gray2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _StepperButton(
                                      label: '-',
                                      onPressed: _decrementWindow,
                                      disabled: _markingWindow <= 5,
                                    ),
                                    Text(
                                      '$_markingWindow min',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: primary,
                                      ),
                                    ),
                                    _StepperButton(
                                      label: '+',
                                      onPressed: _incrementWindow,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for fixed button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bg.withOpacity(0),
                    bg.withOpacity(1),
                    bg,
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Start session
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 8,
                  shadowColor: primary.withOpacity(0.4),
                ),
                child: const Text(
                  'Ouvrir la session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  const _CircularButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = const Color(0xFF092C4C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F092C4C),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showArrow;

  const _DetailRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF092C4C),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4F4F4F),
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFBDBDBD),
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Color(0xFFE0E0E0)),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool disabled;

  const _StepperButton({
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: disabled ? const Color(0xFFE0E0E0) : const Color(0xFFE0E0E0)),
          boxShadow: disabled ? null : const [
            BoxShadow(
              color: Color(0x0F092C4C),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: disabled ? const Color(0xFFBDBDBD) : const Color(0xFF092C4C),
          ),
        ),
      ),
    );
  }
}
