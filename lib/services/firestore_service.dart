import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/member.dart';

class FirestoreService {
  final _eventsRef = FirebaseFirestore.instance.collection('events');
  final _membersRef = FirebaseFirestore.instance.collection('members');

  Stream<List<ChessEvent>> getEventsByType(String type) {
    return _eventsRef
        .where('type', isEqualTo: type)
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => ChessEvent.fromFirestore(
          doc.data(),
          doc.id,
        ),
      )
          .toList(),
    );
  }

  // getting the  live updates for a single event for RSVP count
  Stream<ChessEvent> getEventById(String id) {
    return _eventsRef.doc(id).snapshots().map((doc) {
      return ChessEvent.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  Stream<Member?> getMemberById(String uid) {
    return _membersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Member.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    });
  }


  // added RSVP to event
  Future<void> rsvpToEvent({
    required String eventId,
    required String name,
  }) {
    return _eventsRef.doc(eventId).update({
      'rsvpNames': FieldValue.arrayUnion([name]),
    });
  }

  //members
  Stream<List<Member>> getMembers() {
    return _membersRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map(
          (doc) => Member.fromFirestore(
        doc.data(),
        doc.id,
      ),
    )
        .toList());
  }



  // Create a new event/tournament
  Future<void> createEvent({
    required String title,
    required String type, // "event" or "tournament"
    required DateTime startTime,
    required String location,
    required String description,
    required bool isOnline,
  }) {
    return _eventsRef.add({
      'title': title,
      'type': type,
      'startTime': Timestamp.fromDate(startTime),
      'location': location,
      'description': description,
      'isOnline': isOnline,
      'rsvpNames': <String>[],
    });
  }

// Update existing event
  Future<void> updateEvent(ChessEvent event) {
    return _eventsRef.doc(event.id).update({
      'title': event.title,
      'type': event.type,
      'startTime': Timestamp.fromDate(event.startTime),
      'location': event.location,
      'description': event.description,
      'isOnline': event.isOnline,
      'rsvpNames': event.rsvpNames,
    });
  }

// Delete event
  Future<void> deleteEvent(String eventId) {
    return _eventsRef.doc(eventId).delete();
  }

// Delete member
  Future<void> deleteMember(String memberId) {
    return _membersRef.doc(memberId).delete();
  }

}
