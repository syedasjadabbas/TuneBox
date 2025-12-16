import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:music_player/config/theme.dart';
import 'package:music_player/firebase_options.dart';
import 'package:music_player/pages/root_shell.dart';
import 'package:music_player/pages/auth/login_screen.dart';
import 'package:music_player/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase first
  await SupabaseService.init();
  
  // Initialize Firebase (for cloud songs)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TuneBox',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _supabase = SupabaseService.client;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (mounted) {
        setState(() {
          _isAuthenticated = event == AuthChangeEvent.signedIn || 
                            event == AuthChangeEvent.tokenRefreshed ||
                            _supabase.auth.currentUser != null;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _checkAuthState() async {
    // Check if user is authenticated
    final user = _supabase.auth.currentUser;
    final session = _supabase.auth.currentSession;
    
    setState(() {
      _isAuthenticated = user != null && session != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated ? const RootShell() : const LoginScreen();
  }
}
