import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/evento_model.dart';

class EventosProvider extends ChangeNotifier {
  final eventosRef = FirebaseFirestore.instance.collection('eventos');

  List<EventoModel> eventos = [];
  StreamSubscription? _eventosSub;

  Future<void> cargarEventos(String empresa) async {
    await _eventosSub?.cancel();

    _eventosSub = eventosRef
        .where('empresa', isEqualTo: empresa)
        .snapshots()
        .listen((snapshot) {
          eventos = snapshot.docs.map((doc) {
            final data = doc.data();
            return EventoModel.fromMap(data, doc.id);
          }).toList();

          // 🔥 orden seguro
          eventos.sort((a, b) {
            try {
              final da = DateTime.tryParse(a.fecha) ?? DateTime(1970);
              final db = DateTime.tryParse(b.fecha) ?? DateTime(1970);
              return db.compareTo(da); // más reciente primero
            } catch (_) {
              return 0;
            }
          });

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
