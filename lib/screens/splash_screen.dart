import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          _progress = i / 100;
        });
      }
    }
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          // Logo Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
            ),
            child: const Icon(Icons.security, size: 80, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 48),
          Text(
            'Diesel Cash & Carry',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 8),
          const Text(
            'ADMIN CONSOLE',
            style: TextStyle(
              color: AppTheme.primaryGreen,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(flex: 2),
          // Progress Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Column(
              children: [
                const Text(
                  'Initializing secure connection...',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: AppTheme.bgGrey,
                    color: AppTheme.primaryGreen,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
          // Footer
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined, size: 16, color: AppTheme.textGrey),
              SizedBox(width: 8),
              Text(
                'SECURE ENVIRONMENT',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  letterSpacing: 2,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
