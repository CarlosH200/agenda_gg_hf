import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/evento_model.dart';

class CalendarioWidget extends StatefulWidget {
  final List<EventoModel> eventos;

  const CalendarioWidget({super.key, required this.eventos});

  @override
  State<CalendarioWidget> createState() => _CalendarioWidgetState();
}

class _CalendarioWidgetState extends State<CalendarioWidget> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  final Color primaryColor = const Color(0xFF1F2937);

  List<EventoModel> obtenerEventosDelDia(DateTime dia) {
    return widget.eventos.where((evento) {
      final fecha = DateTime.parse(evento.fecha);

      return fecha.year == dia.year &&
          fecha.month == dia.month &&
          fecha.day == dia.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// CALENDARIO
        Container(
          padding: const EdgeInsets.all(10),

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

          child: TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),

            focusedDay: focusedDay,

            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },

            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },

            /// ESTILOS
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,

              defaultTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),

              weekendTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),

              outsideTextStyle: TextStyle(color: Colors.grey.shade400),

              todayTextStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),

              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),

              todayDecoration: BoxDecoration(
                color: primaryColor.withOpacity(0.25),
                shape: BoxShape.circle,
              ),

              selectedDecoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
            ),

            /// HEADER
            headerStyle: HeaderStyle(
              titleCentered: true,

              formatButtonVisible: false,

              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),

              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: primaryColor,
              ),

              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: primaryColor,
              ),
            ),

            /// DIAS SEMANA
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),

              weekendStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),

            /// EVENTOS
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final fecha =
                    '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

                final tieneEventos = widget.eventos.any(
                  (e) => e.fecha == fecha,
                );

                if (!tieneEventos) return null;

                return Positioned(
                  bottom: 4,

                  child: Container(
                    width: 7,
                    height: 7,

                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// EVENTOS DEL DIA
        Expanded(
          child: ListView(
            children: obtenerEventosDelDia(selectedDay ?? focusedDay).map((
              evento,
            ) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(color: Colors.grey.shade200),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      evento.titulo,

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      evento.descripcion,

                      style: TextStyle(color: Colors.grey.shade700),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: primaryColor,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          evento.fecha,

                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
