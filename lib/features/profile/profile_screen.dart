import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syndory_prof/data/supabase/supabase_client.dart';
import '../auth/auth_gate.dart';
import '../notifications/notifications_screen.dart';

enum ProfileUiState {
  loaded,
  loading,
  editingEmail,
  editingPhone,
  changingPassword,
  confirmLogout,
}

class ProfilePreview {
  final String initials;
  final String name;
  final String specialty;
  String email;
  String phone;
  final List<String> subjects;
  final List<String> classes;

  ProfilePreview({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.email,
    required this.phone,
    required this.subjects,
    required this.classes,
  });
}

class _Assignments {
  final List<String> subjects;
  final List<String> classes;

  const _Assignments({required this.subjects, required this.classes});

  static const empty = _Assignments(subjects: [], classes: []);
}

class ProfileScreen extends StatefulWidget {
  final ProfileUiState initialState;
  const ProfileScreen({super.key, this.initialState = ProfileUiState.loaded});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileUiState _state;
  late ProfilePreview _preview;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  bool _isUpdatingPhone = false;

  @override
  void initState() {
    super.initState();
    _state = ProfileUiState.loading;
    _preview = ProfilePreview(
      initials: '',
      name: '',
      specialty: '',
      email: '',
      phone: '',
      subjects: [],
      classes: [],
    );
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    // Charge le profil réel depuis Supabase si la session est présente.
    _loadProfile();
  }

  String _stringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  String _firstNonEmpty(Iterable<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }

  String _labelFromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return '';
    }
    return _firstNonEmpty([
      _stringValue(data['name']),
      _stringValue(data['code']),
      _stringValue(data['label']),
      _stringValue(data['title']),
    ]);
  }

  bool _isValidBeninPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final national = digits.startsWith('00229')
        ? digits.substring(5)
        : (digits.startsWith('229') ? digits.substring(3) : digits);
    return RegExp(r'^01\d{8}$').hasMatch(national);
  }

  String _normalizeBeninPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final national = digits.startsWith('00229')
        ? digits.substring(5)
        : (digits.startsWith('229') ? digits.substring(3) : digits);
    return '+229$national';
  }

  String _formatBeninPhone(String input) {
    if (input.trim().isEmpty) {
      return '';
    }
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final national = digits.startsWith('00229')
        ? digits.substring(5)
        : (digits.startsWith('229') ? digits.substring(3) : digits);
    if (national.length != 10) {
      return input;
    }
    return '+229 ${national.substring(0, 2)} ${national.substring(2, 4)} '
        '${national.substring(4, 6)} ${national.substring(6, 8)} '
        '${national.substring(8, 10)}';
  }

  String _phoneDisplay(String input) {
    if (input.trim().isEmpty) {
      return 'Non renseigné';
    }
    return _formatBeninPhone(input);
  }

  Future<void> _loadProfile() async {
    if (!SupabaseClientProvider.isInitialized) {
      if (!mounted) {
        return;
      }
      setState(() => _state = ProfileUiState.loaded);
      return;
    }

    final session = SupabaseClientProvider.client.auth.currentSession;
    if (session == null) {
      // Pas de session — reste en état chargé mais sans données.
      if (!mounted) {
        return;
      }
      setState(() => _state = ProfileUiState.loaded);
      return;
    }

    setState(() => _state = ProfileUiState.loading);

    try {
      final user = SupabaseClientProvider.client.auth.currentUser;
      if (user == null) {
        if (!mounted) {
          return;
        }
        setState(() => _state = ProfileUiState.loaded);
        return;
      }

      final userId = user.id;

      final res = await SupabaseClientProvider.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (!mounted) {
        return;
      }

      final Map<String, dynamic> row = res is Map
          ? Map<String, dynamic>.from(res as Map)
          : <String, dynamic>{};
      final Map<String, dynamic> meta = user.userMetadata == null
          ? <String, dynamic>{}
          : user.userMetadata!;

      final first = _stringValue(row['first_name']);
      final last = _stringValue(row['last_name']);
      final email = _firstNonEmpty([
        _stringValue(row['email']),
        _stringValue(user.email),
      ]);
      final phone = _firstNonEmpty([
        _stringValue(row['phone']),
        _stringValue(meta['phone']),
      ]);
      final department = _firstNonEmpty([
        _stringValue(row['department']),
        _stringValue(row['departement']),
        _stringValue(meta['department']),
        _stringValue(meta['departement']),
        _stringValue(row['role']),
      ]);

      final fullName = [
        first,
        last,
      ].where((value) => value.trim().isNotEmpty).join(' ').trim();

      final initials = _firstNonEmpty([
        (first.isNotEmpty && last.isNotEmpty) ? '${first[0]}${last[0]}' : '',
        email.isNotEmpty ? email.split('@').first.substring(0, 2) : '',
      ]).toUpperCase();

      final assignments = await _loadAssignments(userId);
      if (!mounted) {
        return;
      }

      _preview = ProfilePreview(
        initials: initials,
        name: _firstNonEmpty([fullName, email]),
        specialty: department,
        email: email,
        phone: phone,
        subjects: assignments.subjects,
        classes: assignments.classes,
      );
      _emailController.text = _preview.email;
      _phoneController.text = _formatBeninPhone(_preview.phone);
      setState(() => _state = ProfileUiState.loaded);
    } catch (e) {
      debugPrint('[ProfileScreen] Error loading profile: $e');
      if (!mounted) {
        return;
      }
      setState(() => _state = ProfileUiState.loaded);
    }
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  Future<_Assignments> _loadAssignments(String userId) async {
    try {
      final rows = await SupabaseClientProvider.client
          .from('professeur_matieres')
          .select('matiere_id,class_id,matieres(*),classes(*)')
          .eq('professor_id', userId);

      final subjects = <String>{};
      final classes = <String>{};

      for (final row in rows as List) {
        final rowMap = Map<String, dynamic>.from(row as Map);
        final matiere = rowMap['matieres'] as Map?;
        final classe = rowMap['classes'] as Map?;

        final matiereLabel = _labelFromMap(
          matiere == null ? null : Map<String, dynamic>.from(matiere),
        );
        final classLabel = _labelFromMap(
          classe == null ? null : Map<String, dynamic>.from(classe),
        );

        if (matiereLabel.isNotEmpty) {
          subjects.add(matiereLabel);
        }

        if (classLabel.isNotEmpty) {
          classes.add(classLabel);
        }
      }

      final subjectList = subjects.toList()..sort();
      final classList = classes.toList()..sort();

      return _Assignments(subjects: subjectList, classes: classList);
    } catch (e) {
      return _Assignments.empty;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _openChangePasswordSheet() {
    setState(() => _state = ProfileUiState.changingPassword);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final currentCtrl = TextEditingController();
        final newCtrl = TextEditingController();
        final confirmCtrl = TextEditingController();
        bool isSubmitting = false;
        String? errorText;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nouveau mot de passe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF092C4C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: currentCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Ancien mot de passe',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ancien mot de passe requis.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Nouveau mot de passe',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Nouveau mot de passe requis.';
                        }
                        if (v.length < 8) {
                          return 'Le mot de passe doit contenir au moins 8 caractères.';
                        }
                        if (v == currentCtrl.text) {
                          return 'Le nouveau mot de passe doit être différent de l\'ancien.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Confirmer le mot de passe',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Veuillez confirmer le mot de passe.';
                        }
                        if (v != newCtrl.text) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        return null;
                      },
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style: const TextStyle(color: Color(0xFFEB5757)),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF092C4C),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF092C4C),
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() {
                                  isSubmitting = true;
                                  errorText = null;
                                });

                                try {
                                  // Optionnel: ré-authentifier pour vérifier l'ancien mot de passe
                                  final user = SupabaseClientProvider
                                      .client
                                      .auth
                                      .currentUser;
                                  final email = user?.email ?? _preview.email;

                                  if (email.isNotEmpty) {
                                    final reauth = await SupabaseClientProvider
                                        .client
                                        .auth
                                        .signInWithPassword(
                                          email: email,
                                          password: currentCtrl.text,
                                        );
                                    if (reauth.session == null) {
                                      setModalState(() {
                                        errorText =
                                            'Ancien mot de passe incorrect.';
                                        isSubmitting = false;
                                      });
                                      return;
                                    }
                                  }

                                  // Met à jour le mot de passe côté Supabase
                                  await SupabaseClientProvider.client.auth
                                      .updateUser(
                                        UserAttributes(password: newCtrl.text),
                                      );

                                  // Vérifie que le State est toujours monté avant d'utiliser le context
                                  if (!mounted) {
                                    setModalState(() {
                                      isSubmitting = false;
                                    });
                                    return;
                                  }

                                  // Ferme la feuille et notifie
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Mot de passe mis à jour.'),
                                    ),
                                  );
                                } catch (e) {
                                  setModalState(() {
                                    errorText = 'Erreur: $e';
                                    isSubmitting = false;
                                  });
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Mettre à jour'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => setState(() => _state = ProfileUiState.loaded));
  }

  void _showLogoutConfirm() {
    setState(() => _state = ProfileUiState.confirmLogout);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Se déconnecter ?'),
          content: const Text(
            'Voulez-vous vraiment fermer votre session ? Vous devrez vous reconnecter pour accéder à vos cours.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _state = ProfileUiState.loaded);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB5757),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                // Ferme la dialog immédiatement
                navigator.pop();
                setState(() => _state = ProfileUiState.loaded);

                try {
                  await SupabaseClientProvider.client.auth.signOut();
                } catch (_) {}

                if (!mounted) return;

                // Redirige vers l'AuthGate (connexion officielle / placeholder)
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIdCard() {
    if (_state == ProfileUiState.loading) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFE8EFF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(height: 24, width: 180, color: const Color(0xFFE0E0E0)),
            const SizedBox(height: 8),
            Container(height: 16, width: 120, color: const Color(0xFFE0E0E0)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFE8EFF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF092C4C),
            child: Text(
              _preview.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _preview.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF092C4C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _preview.specialty,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4F4F4F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingEmail(),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildSettingPhone(),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildSettingChangePassword(),
        ],
      ),
    );
  }

  Widget _buildSettingEmail() {
    if (_state == ProfileUiState.editingEmail) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.mail_outline, color: Color(0xFF092C4C)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _preview.email = _emailController.text;
                  _state = ProfileUiState.loaded;
                });
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF27AE60),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => setState(() => _state = ProfileUiState.editingEmail),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.mail_outline, color: Color(0xFF092C4C)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'E-mail',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF828282),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _preview.email,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF092C4C),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, color: Color(0xFF2F80ED)),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPhoneUpdate() async {
    if (!_phoneFormKey.currentState!.validate()) return;
    if (!SupabaseClientProvider.isInitialized) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Supabase non initialise.')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final normalized = _normalizeBeninPhone(_phoneController.text);

    setState(() {
      _isUpdatingPhone = true;
    });

    try {
      final user = SupabaseClientProvider.client.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _isUpdatingPhone = false;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('Session invalide. Reconnectez-vous.')),
        );
        return;
      }

      await SupabaseClientProvider.client
          .from('users')
          .update({'phone': normalized})
          .eq('id', user.id);

      await SupabaseClientProvider.client.auth.updateUser(
        UserAttributes(data: {'phone': normalized}),
      );

      if (!mounted) return;
      setState(() {
        _preview.phone = normalized;
        _phoneController.text = _formatBeninPhone(normalized);
        _state = ProfileUiState.loaded;
        _isUpdatingPhone = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Téléphone mis à jour.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUpdatingPhone = false;
      });
      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Widget _buildSettingPhone() {
    if (_state == ProfileUiState.editingPhone) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _phoneFormKey,
          child: Row(
            children: [
              const Icon(Icons.phone, color: Color(0xFF092C4C)),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    hintText: '+229 01 23 45 67 89',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Numéro requis.';
                    }
                    if (!_isValidBeninPhone(v)) {
                      return 'Format attendu: +229 01 XX XX XX XX.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _isUpdatingPhone ? null : _submitPhoneUpdate,
                child: Text(
                  _isUpdatingPhone ? '...' : 'OK',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF27AE60),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        setState(() {
          _phoneController.text = _formatBeninPhone(_preview.phone);
          _state = ProfileUiState.editingPhone;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.phone, color: Color(0xFF092C4C)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Téléphone',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF828282),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _phoneDisplay(_preview.phone),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _preview.phone.trim().isEmpty
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFF092C4C),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, color: Color(0xFF2F80ED)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingChangePassword() {
    return InkWell(
      onTap: _openChangePasswordSheet,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF092C4C)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Changer de mot de passe',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF092C4C),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow('Matières enseignées', _preview.subjects),
          const SizedBox(height: 12),
          _buildInfoRow('Classes assignées', _preview.classes),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF828282),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: values
              .map(
                (v) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    v,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF092C4C),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 16;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mon profil',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF092C4C),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF4F4F4F),
            ),
            onPressed: _openNotifications,
          ),
          IconButton(
            icon: Icon(
              _state == ProfileUiState.loading
                  ? Icons.hourglass_top
                  : Icons.refresh,
              color: const Color(0xFF4F4F4F),
            ),
            onPressed: _state == ProfileUiState.loading ? null : _loadProfile,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _buildIdCard(),
              const SizedBox(height: 16),
              const Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF828282),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsGroup(),
              const SizedBox(height: 16),
              const Text(
                'Affectations',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF828282),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoBox(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _showLogoutConfirm,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEB5757), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEB5757),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
