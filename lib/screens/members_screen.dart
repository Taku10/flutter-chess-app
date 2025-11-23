import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/member.dart';

class MembersScreen extends StatelessWidget {
  final bool isOfficer;
  const MembersScreen({super.key, required this.isOfficer});

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

            final tile = ListTile(
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
            );

            if (!isOfficer) return Card(margin: const EdgeInsets.symmetric(vertical: 6), child: tile);

            // Officers: can swipe to delete
            return Dismissible(
              key: ValueKey(m.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete member'),
                    content: Text('Remove ${m.name} from members?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ) ??
                    false;
              },
              onDismissed: (_) async {
                await FirestoreService().deleteMember(m.id);
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: tile,
              ),
            );
          },
        );

      },
    );
  }
}
