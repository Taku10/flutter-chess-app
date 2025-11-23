import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/chess_com_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _chessComCtrl = TextEditingController();

  String? _yearInSchool;
  bool _isLoading = false;
  String? _errorText;

  // Officer optional toggle (keep if you're using officer code later)
  bool _wantsOfficer = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ratingCtrl.dispose();
    _majorCtrl.dispose();
    _chessComCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // 1. Create Firebase Auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final user = cred.user;
      final name = _nameCtrl.text.trim();
      final major = _majorCtrl.text.trim();
      final year = _yearInSchool;
      final chessUsername = _chessComCtrl.text.trim();

      int? rating;

      // Try parse manual rating if provided
      if (_ratingCtrl.text.trim().isNotEmpty) {
        final value = int.tryParse(_ratingCtrl.text.trim());
        if (value != null) rating = value;
      }

      int? chessComRapidRating;

      // 2. If they entered a Chess.com username, prefer Chess.com rating
      if (chessUsername.isNotEmpty) {
        final chessService = ChessComService();
        chessComRapidRating =
        await chessService.fetchRapidRating(chessUsername);

        if (chessComRapidRating != null) {
          rating = chessComRapidRating;
        }
      }

      if (user != null) {
        await user.updateDisplayName(name);

        // 3. Save member profile in Firestore
        await FirebaseFirestore.instance
            .collection('members')
            .doc(user.uid)
            .set({
          'name': name,
          'email': user.email,
          'rating': rating,
          'yearInSchool': year,
          'major': major,
          'chessComUsername': chessUsername.isEmpty ? null : chessUsername,
          'chessComRapidRating': chessComRapidRating,
          'isOfficer': _wantsOfficer, // change this logic if you use officer code
        });
      }

      if (mounted) Navigator.of(context).pop(); // back to SignInScreen; AuthGate will then go to Home
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = e.message ?? 'Sign up failed';
      });
    } catch (_) {
      setState(() {
        _errorText = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B192F),
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Join CSS Chess Club',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a password';
                        }
                        if (value.length < 6) {
                          return 'At least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Rating (optional, may be overridden by chess.com)
                    TextFormField(
                      controller: _ratingCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Approximate rating (optional)',
                        prefixIcon: Icon(Icons.bar_chart),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Year in school
                    DropdownButtonFormField<String>(
                      initialValue: _yearInSchool,
                      decoration: const InputDecoration(
                        labelText: 'Year in school',
                        prefixIcon: Icon(Icons.school),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'First-year',
                          child: Text('First-year'),
                        ),
                        DropdownMenuItem(
                          value: 'Sophomore',
                          child: Text('Sophomore'),
                        ),
                        DropdownMenuItem(
                          value: 'Junior',
                          child: Text('Junior'),
                        ),
                        DropdownMenuItem(
                          value: 'Senior',
                          child: Text('Senior'),
                        ),
                        DropdownMenuItem(
                          value: 'Graduate',
                          child: Text('Graduate'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _yearInSchool = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Major
                    TextFormField(
                      controller: _majorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Major',
                        prefixIcon: Icon(Icons.menu_book),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Chess.com username (optional)
                    TextFormField(
                      controller: _chessComCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Chess.com username (optional)',
                        prefixIcon: Icon(Icons.sports_esports), // if this errors, change to Icons.sports_esports
                      ),
                    ),
                    const SizedBox(height: 12),

                    // (Optional) officer toggle – keep or remove depending on your logic
                    CheckboxListTile(
                      title: const Text('I am a club officer'),
                      value: _wantsOfficer,
                      onChanged: (value) {
                        setState(() {
                          _wantsOfficer = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    if (_errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        child: _isLoading
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Create account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
