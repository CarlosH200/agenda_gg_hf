import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/evento_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<EventoModel>> obtenerEventos(String empresa) {
    return _db
        .collection('eventos')
        .where('empresa', isEqualTo: empresa)
        .orderBy('fecha')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return EventoModel(
              id: doc.id,
              titulo: data['titulo'],
              descripcion: data['descripcion'],
              fecha: data['fecha'],
              empresa: data['empresa'],
            );
          }).toList();
        });
  }

  Future<void> agregarEvento(EventoModel evento) async {
    await _db.collection('eventos').add({
      'titulo': evento.titulo,
      'descripcion': evento.descripcion,
      'fecha': evento.fecha,
      'empresa': evento.empresa,
    });
  }

  Future<void> editarEvento(EventoModel evento) async {
    await _db.collection('eventos').doc(evento.id).update({
      'titulo': evento.titulo,
      'descripcion': evento.descripcion,
      'fecha': evento.fecha,
      'empresa': evento.empresa,
    });
  }

  Future<void> eliminarEvento(String id) async {
    await _db.collection('eventos').doc(id).delete();
  }
}
