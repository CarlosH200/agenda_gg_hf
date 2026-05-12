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

  final Color primaryColor = const Color(0xFF1F2937);
  final Color accentColor = const Color(0xFF374151);
  final Color backgroundColor = const Color(0xFFF5F5F5);

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

      /// COLORES DEL CALENDARIO
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
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
      mensaje("Completa todos los campos");
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

    try {
      await context.read<EventosProvider>().agregarEvento(evento);

      if (!mounted) return;

      tituloController.clear();
      descripcionController.clear();

      setState(() {
        fechaSeleccionada = null;
        mostrarFormulario = false;
      });

      mensaje("Evento creado correctamente");
    } catch (e) {
      if (!mounted) return;

      mensaje("Error al crear el evento");
    }
  }

  void habilitarFormulario() {
    setState(() {
      limpiarFormulario();

      if (!mostrarFormulario) {
        mostrarFormulario = true;
      } else {
        mostrarFormulario = false;
      }
    });
  }

  void mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 2)),
    );
  }

  void limpiarFormulario() {
    tituloController.clear();
    descripcionController.clear();
    fechaSeleccionada = null;
  }

  @override
  Widget build(BuildContext context) {
    final empresaProvider = context.watch<EmpresaProvider>();

    final eventosProvider = context.watch<EventosProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: SizedBox(
          height: 48,
          width: 140,
          child: Image.asset(
            empresaProvider.empresaActual == 'golden'
                ? 'assets/GoldenGarden.png'
                : 'assets/HoraDeFiesta.png',
            fit: BoxFit.contain,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: habilitarFormulario,

              icon: Icon(
                mostrarFormulario ? Icons.close_rounded : Icons.add_rounded,
                size: 18,
              ),

              label: Text(
                mostrarFormulario ? "Cerrar" : "Nuevo",
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              /// CONTENIDO SUPERIOR SCROLLEABLE
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,

                  child: Column(
                    children: [
                      /// SELECT EMPRESA
                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(color: Colors.grey.shade300),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: empresaProvider.empresaActual,

                            isExpanded: true,

                            borderRadius: BorderRadius.circular(18),

                            dropdownColor: Colors.white,

                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: primaryColor,
                            ),

                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),

                            items: const [
                              DropdownMenuItem(
                                value: 'golden',

                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0xFFF3F4F6),

                                      child: Icon(
                                        Icons.celebration_rounded,
                                        color: Color(0xFF374151),
                                        size: 18,
                                      ),
                                    ),

                                    SizedBox(width: 12),

                                    Text(
                                      'Golden Garden',

                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              DropdownMenuItem(
                                value: 'party',

                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Color(0xFFF3F4F6),

                                      child: Icon(
                                        Icons.cake_rounded,
                                        color: Color(0xFF374151),
                                        size: 18,
                                      ),
                                    ),

                                    SizedBox(width: 12),

                                    Text(
                                      'Hora de Fiesta',

                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            onChanged: (value) {
                              if (value == null) return;

                              empresaProvider.cambiarEmpresa(value);

                              context.read<EventosProvider>().cargarEventos(
                                value,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// FORMULARIO
                      if (mostrarFormulario) ...[
                        Container(
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(20),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              /// TITULO
                              TextField(
                                controller: tituloController,

                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),

                                decoration: InputDecoration(
                                  labelText: 'Título',

                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),

                                  filled: true,
                                  fillColor: Colors.grey.shade100,

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// DESCRIPCION
                              TextField(
                                controller: descripcionController,

                                maxLines: 3,

                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),

                                decoration: InputDecoration(
                                  labelText: 'Descripción',

                                  labelStyle: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),

                                  filled: true,
                                  fillColor: Colors.grey.shade100,

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// FECHA
                              SizedBox(
                                width: double.infinity,
                                height: 52,

                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,

                                    foregroundColor: Colors.white,

                                    elevation: 0,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),

                                  onPressed: seleccionarFecha,

                                  icon: const Icon(Icons.calendar_month),

                                  label: Text(
                                    fechaSeleccionada == null
                                        ? 'Seleccionar Fecha'
                                        : fechaSeleccionada.toString().split(
                                            ' ',
                                          )[0],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// BOTONES
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width < 400
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width /
                                                  2) -
                                              30,

                                    height: 52,

                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,

                                        foregroundColor: Colors.white,

                                        elevation: 0,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),

                                      onPressed: guardarEvento,

                                      icon: const Icon(Icons.save),

                                      label: const Text('Guardar'),
                                    ),
                                  ),

                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width < 400
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width /
                                                  2) -
                                              30,

                                    height: 52,

                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade200,

                                        foregroundColor: Colors.black87,

                                        elevation: 0,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),

                                      onPressed: () {
                                        setState(() {
                                          mostrarFormulario = false;
                                        });
                                      },

                                      icon: const Icon(Icons.close),

                                      label: const Text('Cancelar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],

                      /// BOTONES LISTA / CALENDARIO
                      Container(
                        padding: const EdgeInsets.all(4),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !mostrarCalendario
                                      ? primaryColor
                                      : Colors.transparent,

                                  foregroundColor: !mostrarCalendario
                                      ? Colors.white
                                      : Colors.black87,

                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                onPressed: () {
                                  setState(() {
                                    mostrarCalendario = false;
                                  });
                                },

                                icon: const Icon(Icons.list),

                                label: const Text('Lista'),
                              ),
                            ),

                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mostrarCalendario
                                      ? primaryColor
                                      : Colors.transparent,

                                  foregroundColor: mostrarCalendario
                                      ? Colors.white
                                      : Colors.black87,

                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

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
                      ),

                      const SizedBox(height: 16),

                      /// CONTENIDO
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,

                        child: eventosProvider.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                ),
                              )
                            : mostrarCalendario
                            ? CalendarioWidget(eventos: eventosProvider.eventos)
                            : Builder(
                                builder: (context) {
                                  final eventos = [...eventosProvider.eventos];

                                  eventos.sort((a, b) {
                                    return DateTime.parse(
                                      a.fecha,
                                    ).compareTo(DateTime.parse(b.fecha));
                                  });

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

                                    final key =
                                        '${meses[fecha.month]} - ${fecha.year}';

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Container(
                                            width: double.infinity,

                                            margin: const EdgeInsets.only(
                                              bottom: 10,
                                              top: 8,
                                            ),

                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),

                                            decoration: BoxDecoration(
                                              color: primaryColor,

                                              borderRadius:
                                                  BorderRadius.circular(16),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
