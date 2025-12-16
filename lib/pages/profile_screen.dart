import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_player/services/supabase_client.dart';
import 'package:music_player/pages/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = SupabaseService.client;

  String userName = '';
  String userEmail = '';
  String profilePhotoUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        // User signed out, reload data (will show empty state)
        _loadUserData();
      } else if (event == AuthChangeEvent.signedIn) {
        // User signed in, reload data
        _loadUserData();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            userName = '';
            userEmail = '';
            profilePhotoUrl = '';
            isLoading = false;
          });
        }
        return;
      }

      // Get profile from Supabase using RPC
      final response = await _supabase.rpc('get_my_profile').timeout(
        const Duration(seconds: 8),
      );

      if (!mounted) return;

      if (response != null) {
        final data = response as Map<String, dynamic>;
        setState(() {
          userName = (data['name'] as String?)?.trim().isNotEmpty == true
              ? data['name'] as String
              : 'User';
          userEmail = currentUser.email ?? '';
          profilePhotoUrl = data['photo_url'] as String? ?? '';
          isLoading = false;
        });
      } else {
        // Profile doesn't exist, create it
        await _createProfile();
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint('User data load timed out: $e');
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _createProfile() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return;

      await _supabase.rpc('upsert_profile', params: {
        'p_name': currentUser.email?.split('@')[0] ?? 'User',
        'p_photo_url': '',
      });

      await _loadUserData();
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: userName,
          currentPhotoUrl: profilePhotoUrl,
          onUpdate: _loadUserData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _supabase.auth.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.white60,
              ),
              SizedBox(height: 20),
              Text(
                'Please sign in to view your profile',
                style: TextStyle(color: Colors.white60),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B6B),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              // Profile Photo
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFF2D2D2D),
                  backgroundImage: profilePhotoUrl.isNotEmpty
                      ? NetworkImage(profilePhotoUrl)
                      : null,
                  child: profilePhotoUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white70,
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),
              // User Name
              Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // User Email
              Text(
                userEmail,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              // Edit Profile Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ElevatedButton.icon(
                  onPressed: _navigateToEditProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: Icon(Icons.edit),
                  label: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Profile Info Cards
              _buildInfoCard('Account Info', Icons.info_outline),
              SizedBox(height: 12),
              _buildInfoCard('Settings', Icons.settings_outlined),
              SizedBox(height: 12),
              _buildInfoCard('Privacy Policy', Icons.privacy_tip_outlined),
              SizedBox(height: 12),
              _buildLogoutCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFFFF6B6B)),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.white38,
          size: 16,
        ),
        onTap: () {
          // Add navigation to respective screens
        },
      ),
    );
  }

  Widget _buildLogoutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.logout, color: Color(0xFFFF6B6B)),
        title: Text(
          'Logout',
          style: TextStyle(
            color: Color(0xFFFF6B6B),
            fontSize: 16,
          ),
        ),
        onTap: () async {
          try {
            await _supabase.auth.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error signing out: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentPhotoUrl;
  final VoidCallback onUpdate;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentPhotoUrl,
    required this.onUpdate,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _supabase = SupabaseService.client;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _photoUrlController.text = widget.currentPhotoUrl;
  }

  Future<void> _saveProfile() async {
    setState(() {
      isSaving = true;
    });

    try {
      await _supabase.rpc('upsert_profile', params: {
        'p_name': _nameController.text.trim(),
        'p_photo_url': _photoUrlController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      widget.onUpdate();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Color(0xFF2D2D2D),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2D2D2D)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _photoUrlController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Photo URL',
                labelStyle: TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Color(0xFF2D2D2D),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2D2D2D)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }
}
