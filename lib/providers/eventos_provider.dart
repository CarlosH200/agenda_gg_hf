import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/evento_model.dart';

class EventosProvider extends ChangeNotifier {
  final eventosRef = FirebaseFirestore.instance.collection('eventos');

  List<EventoModel> eventos = [];
  StreamSubscription? _eventosSub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _loadingStart;

  Future<void> cargarEventos(String empresa) async {
    await _eventosSub?.cancel();

    // 🔥 activar loading
    _isLoading = true;
    _loadingStart = DateTime.now();
    notifyListeners();

    _eventosSub = eventosRef
        .where('empresa', isEqualTo: empresa)
        .snapshots()
        .listen((snapshot) async {
          eventos = snapshot.docs.map((doc) {
            final data = doc.data();
            return EventoModel.fromMap(data, doc.id);
          }).toList();

          // ordenar por fecha (más reciente primero)
          eventos.sort((a, b) {
            final da = DateTime.tryParse(a.fecha) ?? DateTime(1970);
            final db = DateTime.tryParse(b.fecha) ?? DateTime(1970);
            return db.compareTo(da);
          });

          // 🔥 mínimo 2.5 segundos de loading (UX suave)
          final elapsed = DateTime.now()
              .difference(_loadingStart!)
              .inMilliseconds;

          const minDelay = 2500;

          if (elapsed < minDelay) {
            await Future.delayed(Duration(milliseconds: minDelay - elapsed));
          }

          // 🔥 apagar loading
          _isLoading = false;
          notifyListeners();
        });
  }

  Future<void> agregarEvento(EventoModel evento) async {
    await eventosRef.add(evento.toMap());
  }

  Future<void> eliminarEvento(String id) async {
    if (id.isEmpty) return;
    await eventosRef.doc(id).delete();
  }

  Future<void> editarEvento(EventoModel evento) async {
    if (evento.id.isEmpty) return;
    await eventosRef.doc(evento.id).update(evento.toMap());
  }

  @override
  void dispose() {
    _eventosSub?.cancel();
    super.dispose();
  }
}
