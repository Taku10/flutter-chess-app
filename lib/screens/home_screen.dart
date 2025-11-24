import 'package:flutter/material.dart';
import 'events_list_screen.dart';
import 'members_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_form_screen.dart';
import 'auth/sign_in_screen.dart';
import '../models/member.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 = Events, 1 = Tournaments, 2 = Members
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Failsafe – normally handled by AuthGate
      return const SignInScreen();
    }

    final service = FirestoreService();

    return StreamBuilder<Member?>(
      stream: service.getMemberById(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B192F),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isOfficer = snapshot.data?.isOfficer == true;

        final pages = [
          EventsListScreen(type: 'event', isOfficer: isOfficer),
          EventsListScreen(type: 'tournament', isOfficer: isOfficer),
          MembersScreen(isOfficer: isOfficer),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFF0B192F),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CSS Chess Club',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Think ahead. One move at a time.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.grid_on, color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Top hero card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildHeroCard(context),
              ),

              // Chips to toggle section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    _buildToggleChip(label: 'Events', index: 0),
                    _buildToggleChip(label: 'Tournaments', index: 1),
                    _buildToggleChip(label: 'Members', index: 2),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // White sheet with current tab details
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: pages[_selectedIndex],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: isOfficer && _selectedIndex != 2
              ? FloatingActionButton(
            onPressed: () {
              final type =
              _selectedIndex == 0 ? 'event' : 'tournament';
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EventFormScreen(type: type),
                ),
              );
            },
            child: const Icon(Icons.add),
          )
              : null,
        );
      },
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.grid_on,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to CSS Chess Club',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'View upcoming meetups, tournaments, and current members.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip({required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedColor: Colors.greenAccent.withValues(alpha:0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.greenAccent[400] : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
