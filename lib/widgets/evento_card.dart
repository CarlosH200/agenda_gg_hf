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

  Future<void> mostrarConfirmacionEliminar(EventoModel evento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar evento"),
          content: const Text("¿Estás seguro de eliminar este evento?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      try {
        await context.read<EventosProvider>().eliminarEvento(evento.id);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Evento eliminado")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al eliminar evento")),
        );
      }
    }
  }

  void mostrarEditarModal() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          title: const Text(
            'Editar Evento',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black, // 🔥 TEXTO NEGRO
            ),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TÍTULO
                TextField(
                  controller: tituloController,

                  style: const TextStyle(
                    color: Colors.black, // 🔥 TEXTO NEGRO
                    fontSize: 16,
                  ),

                  cursorColor: Colors.black, // 🔥 CURSOR NEGRO

                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: const TextStyle(
                      color: Colors.black, // 🔥 LABEL NEGRO
                    ),

                    filled: true,
                    fillColor: backgroundColor,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// DESCRIPCIÓN
                TextField(
                  controller: descripcionController,

                  style: const TextStyle(
                    color: Colors.black, // 🔥 TEXTO NEGRO
                    fontSize: 16,
                  ),

                  cursorColor: Colors.black, // 🔥 CURSOR NEGRO

                  maxLines: 3,

                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: const TextStyle(
                      color: Colors.black, // 🔥 LABEL NEGRO
                    ),

                    filled: true,
                    fillColor: backgroundColor,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// FECHA
                SizedBox(
                  width: double.infinity,
                  height: 45,

                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: seleccionarFecha,

                    icon: const Icon(Icons.calendar_month, size: 18),

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: guardarCambios,

              icon: const Icon(Icons.save, size: 18),

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
      margin: const EdgeInsets.symmetric(vertical: 5),

      child: Card(
        color: Colors.white,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.shade200),
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITULO
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),

                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Icon(
                      Icons.event_rounded,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      widget.evento.titulo,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// DESCRIPCION
              Padding(
                padding: const EdgeInsets.only(left: 34),

                child: Text(
                  widget.evento.descripcion,

                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// FECHA
              Padding(
                padding: const EdgeInsets.only(left: 34),

                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: accentColor,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      widget.evento.fecha,

                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              /// BOTONES
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: () {
                          mostrarEditarModal();
                        },

                        icon: const Icon(Icons.edit, size: 16),

                        label: const Text(
                          'Editar',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: SizedBox(
                      height: 38,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        onPressed: () {
                          mostrarConfirmacionEliminar(widget.evento);
                        },

                        icon: const Icon(Icons.delete, size: 16),

                        label: const Text(
                          'Eliminar',
                          style: TextStyle(fontSize: 13),
                        ),
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
