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

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
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
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          final fecha =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

          final tieneEventos = widget.eventos.any((e) => e.fecha == fecha);

          if (!tieneEventos) return null;

          return Positioned(
            bottom: 1,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
