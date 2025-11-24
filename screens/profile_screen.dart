import 'package:flutter/material.dart';
import 'package:bookverse/services/auth_service.dart';
import 'package:bookverse/services/firebase_service.dart';
import 'package:bookverse/models/user_model.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      final userData = await _firebaseService.getUser(currentUser.uid);
      setState(() {
        _user = userData;
      });
    }
  }

  void _signOut() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserInfo(),
          SizedBox(height: 24),
          _buildReadingStats(),
          SizedBox(height: 24),
          _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _user!.photoURL.isNotEmpty
                  ? NetworkImage(_user!.photoURL)
                  : null,
              child: _user!.photoURL.isEmpty
                  ? Icon(Icons.person, size: 40)
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user!.displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3047),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _user!.email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Chip(
                    label: Text('Reader Level: ${_getReaderLevel()}'),
                    backgroundColor: Color(0xFFE84855).withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingStats() {
    final progress = _user!.totalBooksRead / _user!.readingGoal;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3047),
              ),
            ),
            SizedBox(height: 16),
            LinearPercentIndicator(
              animation: true,
              lineHeight: 20.0,
              animationDuration: 1000,
              percent: progress > 1 ? 1.0 : progress,
              center: Text(
                "${_user!.totalBooksRead}/${_user!.readingGoal}",
                style: TextStyle(color: Colors.white),
              ),
              progressColor: Color(0xFF2D3047),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Books Read', _user!.totalBooksRead.toString()),
                _buildStatItem('Current Streak', '${_user!.currentStreak} days'),
                _buildStatItem('Goal', '${_user!.readingGoal} books'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE84855),
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3047),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAchievementChip('📚 First Book', _user!.totalBooksRead > 0),
                _buildAchievementChip('🔥 7-Day Streak', _user!.currentStreak >= 7),
                _buildAchievementChip('🎯 Goal Achiever', _user!.totalBooksRead >= _user!.readingGoal),
                _buildAchievementChip('⭐ 10 Books', _user!.totalBooksRead >= 10),
                _buildAchievementChip('🏆 Book Worm', _user!.totalBooksRead >= 25),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementChip(String label, bool achieved) {
    return Chip(
      label: Text(label),
      backgroundColor: achieved ? Color(0xFFE84855).withOpacity(0.2) : Colors.grey[200],
      avatar: achieved ? Icon(Icons.check, size: 16) : null,
    );
  }

  String _getReaderLevel() {
    if (_user!.totalBooksRead >= 25) return 'Book Worm';
    if (_user!.totalBooksRead >= 10) return 'Avid Reader';
    if (_user!.totalBooksRead >= 5) return 'Regular Reader';
    return 'Beginner';
  }
}
