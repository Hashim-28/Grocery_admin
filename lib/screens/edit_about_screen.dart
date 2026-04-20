import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';

class EditAboutScreen extends StatefulWidget {
  const EditAboutScreen({super.key});

  @override
  State<EditAboutScreen> createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends State<EditAboutScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAbout();
  }

  Future<void> _loadAbout() async {
    final provider = context.read<DataProvider>();
    await provider.fetchAboutApp();
    _controller.text = provider.aboutApp;
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await context.read<DataProvider>().updateAboutApp(_controller.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Updated successfully'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ABOUT APP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen)),
              ),
            )
          else
            TextButton(
              onPressed: _handleSave,
              child: const Text('SAVE', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          if (provider.isAboutAppLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About the App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This information will be displayed to customers in the Help/About section of their app.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 15,
                    decoration: const InputDecoration(
                      hintText: 'Describe your app, its usage, and any other relevant information...',
                      contentPadding: EdgeInsets.all(20),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textDark),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving 
                      ? const Text('SAVING...') 
                      : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
