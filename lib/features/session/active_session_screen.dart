import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/classes_repository.dart';
import '../../data/supabase/supabase_client.dart';
import '../classes/models/models.dart';
import 'session_recap_screen.dart';
import '../notifications/notifications_screen.dart';

class ActiveSessionScreen extends StatefulWidget {
  final ClassModel classInfo;
  final int initialTimerMinutes;
  final String sessionId;

  const ActiveSessionScreen({
    super.key,
    required this.classInfo,
    required this.sessionId,
    this.initialTimerMinutes = 10,
  });

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late int _secondsRemaining;
  late Timer _timer;
  bool _isClosed = false;
  bool _showClosureModal = false;

  StreamSubscription? _presenceSubscription;
  List<Map<String, dynamic>> _presences = [];
  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialTimerMinutes * 60;
    _startTimer();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final students = await ClassesRepository.getStudentsForClass(
        widget.classInfo.id,
      );
      if (mounted) {
        setState(() {
          _allStudents = List<Map<String, dynamic>>.from(students);
          _isLoadingStudents = false;
        });
      }

      _presenceSubscription = SupabaseClientProvider.client
          .from('presences')
          .stream(primaryKey: ['session_id', 'student_id'])
          .eq('session_id', widget.sessionId)
          .listen((data) {
            if (mounted) {
              setState(() {
                _presences = List<Map<String, dynamic>>.from(data);
              });
            }
          });
    } catch (e) {
      debugPrint('[ActiveSession] Error initializing data: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _presenceSubscription?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          _handleAutoClose();
        }
      });
    });
  }

  Future<void> _handleAutoClose() async {
    try {
      await SessionRepository.closeSession(widget.sessionId);
    } catch (e) {
      debugPrint('[ActiveSession] Auto-close error: $e');
    }
    if (mounted) {
      setState(() {
        _isClosed = true;
      });
      _navigateToRecap();
    }
  }

  Future<void> _handleManualClose() async {
    setState(() => _isLoadingClosure = true);
    try {
      await SessionRepository.closeSession(widget.sessionId);
      if (mounted) {
        setState(() {
          _showClosureModal = false;
          _isClosed = true;
          _timer.cancel();
        });
        _navigateToRecap();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la clôture: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingClosure = false);
    }
  }

  bool _isLoadingClosure = false;

  void _navigateToRecap() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SessionRecapScreen(
              classInfo: widget.classInfo,
              sessionId: widget.sessionId,
            ),
          ),
        );
      }
    });
  }

  void _extendSession() {
    setState(() {
      _secondsRemaining += 5 * 60;
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _progress {
    final total = widget.initialTimerMinutes * 60;
    return _secondsRemaining / total;
  }

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF092C4C);
    const Color primaryLight = Color(0xFF0D3A65);
    const Color bg = Color(0xFFF5F7FA);
    const Color error = Color(0xFFEB5757);
    const Color success = Color(0xFF27AE60);
    const Color successDim = Color(0xFFE8F8EF);
    const Color gray2 = Color(0xFF4F4F4F);
    const Color gray3 = Color(0xFF828282);
    const Color gray5 = Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Session en cours',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: primary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      _CircularButton(
                        icon: Icons.notifications_none,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      children: [
                        // Banner
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primary, primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F092C4C),
                                offset: Offset(0, 4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.classInfo.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.classInfo.filiere} • Amphi B204',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Timer Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F092C4C),
                                offset: Offset(0, 4),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'TEMPS RESTANT',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: gray3,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formattedTime,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: primary,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: gray5,
                                  color: gray2,
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Controls
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0F092C4C),
                                      offset: Offset(0, 4),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${_presences.length}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: primary,
                                      ),
                                    ),
                                    Text(
                                      ' / ${_allStudents.length} présents',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: gray3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _ExtendButton(onPressed: _extendSession),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // List Header
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Liste des étudiants',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: gray3,
                              ),
                            ),
                          ),
                        ),

                        // Closure Confirmation Modal
                        if (_showClosureModal && !_isClosed)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _showClosureModal = false),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap:
                                          () {}, // Prevent closing when tapping modal
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          32,
                                          24,
                                          40,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(24),
                                            topRight: Radius.circular(24),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Clore la session ?',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                color: Color(
                                                  0xFF092C4C,
                                                ), // primary
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            const Text(
                                              'Êtes-vous sûr de vouloir clore la session ? Les étudiants n\'ayant pas marqué seront enregistrés comme absents.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(
                                                  0xFF4F4F4F,
                                                ), // gray2
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Column(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: _isLoadingClosure
                                                      ? null
                                                      : _handleManualClose,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: error,
                                                    foregroundColor:
                                                        Colors.white,
                                                    minimumSize: const Size(
                                                      double.infinity,
                                                      56,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            9999,
                                                          ),
                                                    ),
                                                  ),
                                                  child: _isLoadingClosure
                                                      ? const CircularProgressIndicator(
                                                          color: Colors.white,
                                                        )
                                                      : const Text(
                                                          'Clore la session',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(height: 12),
                                                OutlinedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _showClosureModal = false;
                                                    });
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    side: const BorderSide(
                                                      color: gray5,
                                                    ),
                                                    foregroundColor: gray2,
                                                    minimumSize: const Size(
                                                      double.infinity,
                                                      56,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            9999,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Annuler',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Student List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _isLoadingStudents
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  children: _allStudents.map((student) {
                                    final userData =
                                        student['users']
                                            as Map<String, dynamic>;
                                    final studentId = userData['id'] as String;
                                    final firstName =
                                        userData['first_name'] as String;
                                    final lastName =
                                        userData['last_name'] as String;
                                    final initials =
                                        '${firstName[0]}${lastName[0]}';

                                    final presence = _presences.firstWhere(
                                      (p) => p['student_id'] == studentId,
                                      orElse: () => {},
                                    );

                                    final bool hasMarked = presence.isNotEmpty;
                                    final Color bColor = hasMarked
                                        ? success
                                        : gray3;
                                    final Color bBg = hasMarked
                                        ? successDim
                                        : gray5;

                                    return _StudentListItem(
                                      name: '$firstName $lastName',
                                      initials: initials,
                                      status: hasMarked
                                          ? 'Marqué'
                                          : 'En attente...',
                                      badgeLabel: hasMarked ? 'Présent' : '...',
                                      badgeColor: bColor,
                                      badgeBg: bBg,
                                      badgeIcon: hasMarked ? Icons.check : null,
                                      isPending: !hasMarked,
                                    );
                                  }).toList(),
                                ),
                        ),
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
                    bg.withValues(alpha: 0),
                    bg.withValues(alpha: 1),
                    bg,
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showClosureModal = true;
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 8,
                  shadowColor: error.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'Enregistrer mon départ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          // Closed Overlay
          if (_isClosed)
            Positioned.fill(
              child: Container(
                color: primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Fenêtre fermée',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Le temps est écoulé. La session est maintenant close.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Redirection...',
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Retour à l\'accueil',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
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

  const _CircularButton({required this.icon, required this.onPressed});

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
        icon: Icon(icon, color: const Color(0xFF4F4F4F), size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _ExtendButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ExtendButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: const Color(0xFFF2994A), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F092C4C),
              offset: Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.add, color: Color(0xFFF2994A), size: 16),
            SizedBox(width: 6),
            Text(
              '5 min',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF2994A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentListItem extends StatelessWidget {
  final String name;
  final String initials;
  final String status;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBg;
  final IconData? badgeIcon;
  final bool isPending;

  const _StudentListItem({
    required this.name,
    required this.initials,
    required this.status,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBg,
    this.badgeIcon,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EFF5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF092C4C),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPending ? const Color(0xFF828282) : badgeColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (badgeIcon != null) ...[
                  Icon(badgeIcon, color: badgeColor, size: 12),
                  const SizedBox(width: 4),
                ],
                Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
