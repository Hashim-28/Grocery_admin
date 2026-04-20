import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants/supabase_config.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const GroceryAdminApp(),
    ),
  );
}

class GroceryAdminApp extends StatefulWidget {
  const GroceryAdminApp({super.key});

  @override
  State<GroceryAdminApp> createState() => _GroceryAdminAppState();
}

class _GroceryAdminAppState extends State<GroceryAdminApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diesel Cash & Carry Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showSplash
          ? SplashScreen(onFinish: () => setState(() => _showSplash = false))
          : Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isAuthenticated) {
                  return const HomeShell();
                }
                return const AuthScreen();
              },
            ),
    );
  }
}
