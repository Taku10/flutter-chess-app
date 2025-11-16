import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/member.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return StreamBuilder<List<Member>>(
      stream: firestore.getMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          return const Center(child: Text('No members added yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final m = members[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(m.name),
                subtitle: Text(
                  [
                    if (m.rating != null) 'Rating: ${m.rating}',
                    if (m.isOfficer) 'Officer',
                  ].join(' • '),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
