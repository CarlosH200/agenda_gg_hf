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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text('Editar Evento'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
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

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),

            ElevatedButton.icon(
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

      margin: const EdgeInsets.symmetric(vertical: 6),

      child: Card(
        elevation: 4,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  const Icon(Icons.event, color: Colors.orange),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      widget.evento.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                widget.evento.descripcion,
                style: const TextStyle(fontSize: 15),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.orange,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    widget.evento.fecha,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: mostrarEditarModal,

                      icon: const Icon(Icons.edit),

                      label: const Text('Editar'),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
