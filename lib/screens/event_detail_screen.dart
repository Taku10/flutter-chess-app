import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final ChessEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final typeLabel =
    event.type == 'tournament' ? 'Tournament' : 'Club Event';

    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              typeLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(event.startTime),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (event.isOnline)
              Row(
                children: const [
                  Icon(Icons.laptop, size: 20),
                  SizedBox(width: 4),
                  Text('Online event'),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad2(dt.month)}-${_pad2(dt.day)} '
        '${_pad2(dt.hour)}:${_pad2(dt.minute)}';
  }

  String _pad2(int n) => n.toString().padLeft(2, '0');
}
