import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/event.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatelessWidget {
  final String type; // "event" or "tournament"
  const EventsListScreen({super.key, required this.type});

  String get _titleText =>
      type == 'event' ? 'Upcoming Events' : 'Tournaments';

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<ChessEvent>>(
      stream: firestoreService.getEventsByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final events = snapshot.data ?? [];

        if (events.isEmpty) {
          return Center(
            child: Text('No $_titleText yet.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(
                  '${_formatDateTime(event.startTime)} · ${event.location}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: event),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    // Simple formatting: "Nov 15, 7:00 PM"
    return '${_monthShort(dt.month)} ${dt.day}, '
        '${_formatHour(dt.hour)}:${_pad2(dt.minute)} ${dt.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _monthShort(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  String _formatHour(int hour24) {
    final h = hour24 % 12;
    return (h == 0 ? 12 : h).toString();
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');
}
