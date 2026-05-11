import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/evento_model.dart';
import '../providers/eventos_provider.dart';

class EventoCard extends StatefulWidget {
  final EventoModel evento;

  const EventoCard({super.key, required this.evento});

  @override
  State<EventoCard> createState() => _EventoCardState();
}

class _EventoCardState extends State<EventoCard> {
  late TextEditingController tituloController;
  late TextEditingController descripcionController;

  DateTime? fechaSeleccionada;

  final Color primaryColor = const Color(0xFF1F2937);
  final Color accentColor = const Color(0xFF374151);
  final Color backgroundColor = const Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();

    tituloController = TextEditingController(text: widget.evento.titulo);

    descripcionController = TextEditingController(
      text: widget.evento.descripcion,
    );

    fechaSeleccionada = DateTime.tryParse(widget.evento.fecha);
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: fechaSeleccionada ?? DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> guardarCambios() async {
    if (fechaSeleccionada == null) return;

    final fecha =
        '${fechaSeleccionada!.year}-${fechaSeleccionada!.month.toString().padLeft(2, '0')}-${fechaSeleccionada!.day.toString().padLeft(2, '0')}';

    final actualizado = EventoModel(
      id: widget.evento.id,
      titulo: tituloController.text,
      descripcion: descripcionController.text,
      fecha: fecha,
      empresa: widget.evento.empresa,
    );

    await context.read<EventosProvider>().editarEvento(actualizado);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void mostrarEditarModal() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Editar Evento',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: tituloController,

                  decoration: InputDecoration(
                    labelText: 'Título',

                    filled: true,
                    fillColor: backgroundColor,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: descripcionController,

                  maxLines: 3,

                  decoration: InputDecoration(
                    labelText: 'Descripción',

                    filled: true,
                    fillColor: backgroundColor,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,

                      elevation: 0,

                      padding: const EdgeInsets.symmetric(horizontal: 16),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    onPressed: seleccionarFecha,

                    icon: const Icon(Icons.calendar_month),

                    label: Text(
                      fechaSeleccionada == null
                          ? 'Seleccionar Fecha'
                          : fechaSeleccionada.toString().split(' ')[0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),

              child: Text(
                'Cancelar',

                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,

                elevation: 0,

                padding: const EdgeInsets.symmetric(horizontal: 16),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: guardarCambios,

              icon: const Icon(Icons.save),

              label: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),

      child: Card(
        color: Colors.white,

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),

          side: BorderSide(color: Colors.grey.shade200),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITULO
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Container(
                    padding: const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      color: backgroundColor,

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Icon(
                      Icons.event_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      widget.evento.titulo,

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// DESCRIPCION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),

                child: Text(
                  widget.evento.descripcion,

                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// FECHA
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  color: backgroundColor,

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: accentColor,
                    ),

                    const SizedBox(width: 10),

                    Text(
                      widget.evento.fecha,

                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// BOTONES
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          padding: const EdgeInsets.symmetric(horizontal: 14),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        onPressed: mostrarEditarModal,

                        icon: const Icon(Icons.edit),

                        label: const Text('Editar'),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 44,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),

                          foregroundColor: Colors.white,

                          elevation: 0,

                          padding: const EdgeInsets.symmetric(horizontal: 14),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        onPressed: () {
                          context.read<EventosProvider>().eliminarEvento(
                            widget.evento.id,
                          );
                        },

                        icon: const Icon(Icons.delete),

                        label: const Text('Eliminar'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
