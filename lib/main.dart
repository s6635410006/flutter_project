import 'package:flutter/material.dart';
import 'package:flutter_project/views/home_ui.dart';
import 'package:flutter_project/views/login_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//--------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Missing Supabase config. Run with --dart-define=SUPABASE_URL=... and --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(
    const Flutterproject(),
  );
}

//--------------------------------------
class Flutterproject extends StatefulWidget {
  const Flutterproject({super.key});

  @override
  State<Flutterproject> createState() => _FlutterprojectState();
}

class _FlutterprojectState extends State<Flutterproject> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authClient = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: authClient.onAuthStateChange,
      builder: (context, snapshot) {
        final currentSession = authClient.currentSession;
        if (currentSession == null) {
          return const LoginUi();
        }
        return const HomeUi();
      },
    );
  }
}
