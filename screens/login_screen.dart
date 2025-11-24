import 'package:flutter/material.dart';
import 'package:bookverse/services/auth_service.dart';
import 'package:bookverse/services/firebase_service.dart';
import 'package:bookverse/models/user_model.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        
        // Check if user exists, if not create new user
        final existingUser = await _firebaseService.getUser(user.uid);
        if (existingUser == null) {
          final newUser = AppUser(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName ?? 'User',
            photoURL: user.photoURL ?? '',
          );
          await _firebaseService.saveUser(newUser);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3047),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Icon(
                Icons.menu_book,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                'BookVerse',
                style: TextStyle(
                  fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Discover your next favorite book',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.login),
                  label: Text('Sign in with Google'),
                  onPressed: () => _signInWithGoogle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF2D3047),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
