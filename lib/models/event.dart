import 'package:cloud_firestore/cloud_firestore.dart';

class ChessEvent {
  final String id;
  final String title;
  final String type; // "event" or "tournament"
  final DateTime startTime;
  final String location;
  final String description;
  final bool isOnline;

  //for rsvp peopel
  final List<String> rsvpNames;

  int get rsvpCount => rsvpNames.length;

  ChessEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.location,
    required this.description,
    required this.isOnline,
    required this.rsvpNames,
  });

  factory ChessEvent.fromFirestore(Map<String, dynamic> data, String id) {
    return ChessEvent(
      id: id,
      title: data['title'] ?? '',
      type: data['type'] ?? 'event',
      startTime: (data['startTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      isOnline: data['isOnline'] ?? false,
      rsvpNames: (data['rsvpNames'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}
