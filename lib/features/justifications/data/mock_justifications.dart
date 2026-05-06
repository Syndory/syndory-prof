import '../domain/justification_model.dart';

final mockJustifications = [
  Justification(
    id: '1',
    studentId: 'stud_1',
    studentName: 'Hermann Parker',
    studentEmail: 'hermann.parker@syndory.com',
    subjectName: 'Mathématiques Appliquées',
    date: DateTime.now().subtract(const Duration(days: 2)),
    reason: 'Rendez-vous médical urgent.',
    status: JustificationStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Justification(
    id: '2',
    studentId: 'stud_2',
    studentName: 'John Ross',
    studentEmail: 'john.ross@syndory.com',
    subjectName: 'Algorithmique',
    date: DateTime.now().subtract(const Duration(days: 5)),
    reason: 'Problème de transport.',
    status: JustificationStatus.approved,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Justification(
    id: '3',
    studentId: 'stud_3',
    studentName: 'Jeffry Integration',
    studentEmail: 'jeffry.lead@syndory.com',
    subjectName: 'Développement Mobile',
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: JustificationStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];
