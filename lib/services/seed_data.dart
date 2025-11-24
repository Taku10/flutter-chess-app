import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> ensureSeedDataLoaded() async {
  final db = FirebaseFirestore.instance;

  // Check if there is at least 1 event
  final eventsSnapshot =
  await db.collection('events').limit(1).get();

  // Check if there is at least 1 member
  final membersSnapshot =
  await db.collection('members').limit(1).get();

  final hasEvents = eventsSnapshot.docs.isNotEmpty;
  final hasMembers = membersSnapshot.docs.isNotEmpty;

  // If both collections already have data, do nothing
  if (hasEvents && hasMembers) {
    return;
  }

  // Otherwise seed both
  await _seedSampleData(db);
}

Future<void> _seedSampleData(FirebaseFirestore db) async {
  final batch = db.batch();

  // --- Events & tournaments ---
  final events = [
    {
      'title': 'Weekly Club Night',
      'type': 'event',
      'startTime': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 2, hours: 19)),
      ),
      'location': 'Tower Hall – 3rd Floor Lounge',
      'description':
      'Casual games, puzzles, and hanging out. All levels welcome.',
      'isOnline': false,
      'rsvpNames': ['Takunda', 'Simba'],
    },
    {
      'title': 'Beginner Workshop',
      'type': 'event',
      'startTime': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 4, hours: 16)),
      ),
      'location': 'Science Center – Room 110',
      'description':
      'Intro to basic tactics, checkmates, and not blundering your queen.',
      'isOnline': false,
      'rsvpNames': ['Grace'],
    },
    {
      'title': 'Online Lichess Arena Night',
      'type': 'event',
      'startTime': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 6, hours: 20)),
      ),
      'location': 'Online – Lichess',
      'description':
      'Join our Lichess team and play a 1-hour arena with the club.',
      'isOnline': true,
      'rsvpNames': [],
    },
    {
      'title': 'Campus Blitz Championship',
      'type': 'tournament',
      'startTime': Timestamp.fromDate(
        DateTime(DateTime.now().year, 4, 20, 13, 0),
      ),
      'location': 'BWC – Multipurpose Room',
      'description':
      '5-round Swiss, 5+0 blitz. Trophies for top 3 and best newcomer.',
      'isOnline': false,
      'rsvpNames': ['Takunda', 'Alec', 'Jonny'],
    },
    {
      'title': 'Midnight Rapid Madness',
      'type': 'tournament',
      'startTime': Timestamp.fromDate(
        DateTime(DateTime.now().year, 5, 1, 22, 0),
      ),
      'location': 'Library – Silent Study Area',
      'description': '3-round rapid (10+5). Come caffeinated.',
      'isOnline': false,
      'rsvpNames': [],
    },
  ];

  for (final e in events) {
    final doc = db.collection('events').doc();
    batch.set(doc, e);
  }

  // --- Members ---
  final members = [
    {
      'id': 'seed-taku',
      'name': 'Takunda Madziwa',
      'email': 'takunda@example.com',
      'rating': 1450,
      'yearInSchool': 'Sophomore',
      'major': 'Computer Science',
      'chessComUsername': 'taku_css',
      'chessComRapidRating': 1503,
      'isOfficer': true,
    },
    {
      'id': 'seed-simba',
      'name': 'Simba Ndlovu',
      'email': 'simba@example.com',
      'rating': 1300,
      'yearInSchool': 'Junior',
      'major': 'Mathematics',
      'chessComUsername': 'simba_blitz',
      'chessComRapidRating': 1340,
      'isOfficer': false,
    },
    {
      'id': 'seed-grace',
      'name': 'Grace Lee',
      'email': 'grace@example.com',
      'rating': 900,
      'yearInSchool': 'First-year',
      'major': 'Biology',
      'chessComUsername': null,
      'chessComRapidRating': null,
      'isOfficer': false,
    },
    {
      'id': 'seed-jonny',
      'name': 'Jonny Johnson',
      'email': 'jonny@example.com',
      'rating': 1200,
      'yearInSchool': 'Senior',
      'major': 'Finance',
      'chessComUsername': 'jj_endgames',
      'chessComRapidRating': 1255,
      'isOfficer': true,
    },
    {
      'id': 'seed-alec',
      'name': 'Alec Martinez',
      'email': 'alec@example.com',
      'rating': 1000,
      'yearInSchool': 'Graduate',
      'major': 'Data Analytics',
      'chessComUsername': null,
      'chessComRapidRating': null,
      'isOfficer': false,
    },
  ];

  for (final m in members) {
    final doc = db.collection('members').doc(m['id'] as String);
    final copy = Map<String, dynamic>.from(m)..remove('id');
    batch.set(doc, copy);
  }

  await batch.commit();
}
