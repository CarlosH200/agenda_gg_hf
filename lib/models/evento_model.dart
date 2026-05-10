class EventoModel {
  final String id;

  final String titulo;

  final String descripcion;

  final String fecha;

  final String empresa;

  EventoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.empresa,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,

      'descripcion': descripcion,

      'fecha': fecha,

      'empresa': empresa,
    };
  }

  factory EventoModel.fromMap(Map<String, dynamic> map, String documentId) {
    return EventoModel(
      id: documentId,

      titulo: map['titulo'] ?? '',

      descripcion: map['descripcion'] ?? '',

      fecha: map['fecha'] ?? '',

      empresa: map['empresa'] ?? '',
    );
  }
}
