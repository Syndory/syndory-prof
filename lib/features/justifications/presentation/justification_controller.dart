import 'package:flutter/material.dart';
import '../domain/justification_model.dart';
import '../data/justification_repository.dart';

enum JustificationStateStatus { initial, loading, loaded, empty, allCaughtUp, error }

class JustificationState {
  final List<Justification> items;
  final JustificationStateStatus status;
  final String? error;

  JustificationState({
    this.items = const [],
    this.status = JustificationStateStatus.initial,
    this.error,
  });

  JustificationState copyWith({
    List<Justification>? items,
    JustificationStateStatus? status,
    String? error,
  }) {
    return JustificationState(
      items: items ?? this.items,
      status: status ?? this.status,
      error: error,
    );
  }
}

class JustificationController extends ValueNotifier<JustificationState> {
  final JustificationRepository _repository;

  JustificationController({JustificationRepository? repository}) 
    : _repository = repository ?? const JustificationRepository(),
      super(JustificationState());

  Future<void> load() async {
    value = value.copyWith(status: JustificationStateStatus.loading);
    
    try {
      final data = await _repository.fetchAll();
      
      if (data.isEmpty) {
        value = value.copyWith(status: JustificationStateStatus.empty, items: []);
      } else {
        // Si tout est traité (aucun en attente), on pourrait utiliser allCaughtUp
        final hasPending = data.any((j) => j.status == JustificationStatus.pending);
        value = value.copyWith(
          status: hasPending ? JustificationStateStatus.loaded : JustificationStateStatus.allCaughtUp,
          items: data,
        );
      }
    } catch (e) {
      value = value.copyWith(
        status: JustificationStateStatus.error, 
        error: e.toString()
      );
    }
  }

  List<Justification> get pendingItems => 
      value.items.where((j) => j.status == JustificationStatus.pending).toList();

  List<Justification> get processedItems => 
      value.items.where((j) => j.status != JustificationStatus.pending).toList();

  Future<bool> review({
    required String id, 
    required String decision, 
    String? reason
  }) async {
    try {
      await _repository.review(justificatifId: id, decision: decision, rejectionReason: reason);
      await load(); // Rafraîchir les données
      return true;
    } catch (e) {
      // On pourrait gérer l'erreur plus finement ici
      return false;
    }
  }
}
