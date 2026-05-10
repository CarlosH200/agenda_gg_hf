import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/evento_model.dart';
import '../providers/empresa_provider.dart';
import '../providers/eventos_provider.dart';

import '../widgets/calendario_widget.dart';
import '../widgets/evento_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  DateTime? fechaSeleccionada;
  bool mostrarCalendario = false;
  bool cargado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!cargado) {
      final empresa = context.read<EmpresaProvider>().empresaActual;
      context.read<EventosProvider>().cargarEventos(empresa);
      cargado = true;
    }
  }

  Future<void> seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> guardarEvento() async {
    if (tituloController.text.isEmpty ||
        descripcionController.text.isEmpty ||
        fechaSeleccionada == null)
      return;

    final empresa = context.read<EmpresaProvider>().empresaActual;

    final fecha =
        '${fechaSeleccionada!.year}-${fechaSeleccionada!.month.toString().padLeft(2, '0')}-${fechaSeleccionada!.day.toString().padLeft(2, '0')}';

    final evento = EventoModel(
      id: '',
      titulo: tituloController.text,
      descripcion: descripcionController.text,
      fecha: fecha,
      empresa: empresa,
    );

    await context.read<EventosProvider>().agregarEvento(evento);

    tituloController.clear();
    descripcionController.clear();

    setState(() {
      fechaSeleccionada = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final empresaProvider = context.watch<EmpresaProvider>();
    final eventosProvider = context.watch<EventosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda Eventos')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              value: empresaProvider.empresaActual,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'golden', child: Text('Golden Garden')),
                DropdownMenuItem(value: 'party', child: Text('Hora de Fiesta')),
              ],
              onChanged: (value) {
                if (value == null) return;

                empresaProvider.cambiarEmpresa(value);
                context.read<EventosProvider>().cargarEventos(value);
              },
            ),

            const SizedBox(height: 10),

            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: seleccionarFecha,
              child: Text(
                fechaSeleccionada == null
                    ? 'Seleccionar Fecha'
                    : fechaSeleccionada.toString().split(' ')[0],
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: guardarEvento,
              child: const Text('Guardar Evento'),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      mostrarCalendario = false;
                    }),
                    child: const Text('Lista'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      mostrarCalendario = true;
                    }),
                    child: const Text('Calendario'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: mostrarCalendario
                  ? CalendarioWidget(eventos: eventosProvider.eventos)
                  : ListView.builder(
                      itemCount: eventosProvider.eventos.length,
                      itemBuilder: (context, index) {
                        final evento = eventosProvider.eventos[index];
                        return EventoCard(evento: evento);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
