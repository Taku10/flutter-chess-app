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
}
