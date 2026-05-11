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
  bool mostrarFormulario = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final empresa = context.read<EmpresaProvider>().empresaActual;

      context.read<EventosProvider>().cargarEventos(empresa);
    });
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
        fechaSeleccionada == null) {
      return;
    }

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
      mostrarFormulario = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final empresaProvider = context.watch<EmpresaProvider>();

    final eventosProvider = context.watch<EventosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda Eventos'),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                mostrarFormulario = !mostrarFormulario;
              });
            },

            icon: Icon(mostrarFormulario ? Icons.close : Icons.add),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// EMPRESAS
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

            const SizedBox(height: 15),

            /// FORMULARIO
            if (mostrarFormulario) ...[
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

                maxLines: 3,

                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 50,
                width: double.infinity,

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

              const SizedBox(height: 10),

              SizedBox(
                height: 50,
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: guardarEvento,

                  icon: const Icon(Icons.save),

                  label: const Text('Guardar Evento'),
                ),
              ),

              const SizedBox(height: 15),
            ],

            /// BOTONES
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        mostrarCalendario = false;
                      });
                    },

                    icon: const Icon(Icons.list),

                    label: const Text('Lista'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        mostrarCalendario = true;
                      });
                    },

                    icon: const Icon(Icons.calendar_month),

                    label: const Text('Calendario'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// CONTENIDO
            Expanded(
              child: mostrarCalendario
                  ? CalendarioWidget(eventos: eventosProvider.eventos)
                  : Builder(
                      builder: (context) {
                        final eventos = [...eventosProvider.eventos];

                        /// ORDENAR FECHAS
                        eventos.sort((a, b) {
                          return DateTime.parse(
                            a.fecha,
                          ).compareTo(DateTime.parse(b.fecha));
                        });

                        /// AGRUPAR POR MES
                        Map<String, List<EventoModel>> grupos = {};

                        final meses = [
                          '',
                          'ENERO',
                          'FEBRERO',
                          'MARZO',
                          'ABRIL',
                          'MAYO',
                          'JUNIO',
                          'JULIO',
                          'AGOSTO',
                          'SEPTIEMBRE',
                          'OCTUBRE',
                          'NOVIEMBRE',
                          'DICIEMBRE',
                        ];

                        for (var evento in eventos) {
                          final fecha = DateTime.parse(evento.fecha);

                          final key = '${meses[fecha.month]} - ${fecha.year}';

                          if (!grupos.containsKey(key)) {
                            grupos[key] = [];
                          }

                          grupos[key]!.add(evento);
                        }

                        final keys = grupos.keys.toList();

                        return ListView.builder(
                          itemCount: keys.length,

                          itemBuilder: (context, index) {
                            final key = keys[index];

                            final eventosGrupo = grupos[key]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                /// HEADER DEL MES
                                Container(
                                  width: double.infinity,

                                  margin: const EdgeInsets.only(
                                    top: 12,
                                    bottom: 8,
                                  ),

                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.orange,

                                    borderRadius: BorderRadius.circular(14),
                                  ),

                                  child: Text(
                                    key,

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                /// EVENTOS
                                ...eventosGrupo.map((evento) {
                                  return EventoCard(evento: evento);
                                }),
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
