import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. using defaults.");
  }


  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://xyz.supabase.co';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'public-anon-key';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

 
  runApp(
    const ProviderScope(
      child: AaharAIApp(),
    ),
  );
}