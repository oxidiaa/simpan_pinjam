import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with hardcoded credentials
  await Supabase.initialize(
    url: 'https://nafznhxphhuvfbraqjqx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hZnpuaHhwaGh1dmZicmFxanF4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDczMTYyNDgsImV4cCI6MjA2Mjg5MjI0OH0.FSff3H4QSU-jDJfOHiRouw99UP7SKthpQkpWBi9Fvho',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Simpan Pinjam',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
