import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';
import '../models/support_models.dart';

class ManageContactScreen extends StatefulWidget {
  const ManageContactScreen({super.key});

  @override
  State<ManageContactScreen> createState() => _ManageContactScreenState();
}

class _ManageContactScreenState extends State<ManageContactScreen> {
  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'Email', 'icon': Icons.email_outlined},
    {'name': 'Phone', 'icon': Icons.phone_outlined},
    {'name': 'Location', 'icon': Icons.location_on_outlined},
    {'name': 'WhatsApp', 'icon': Icons.chat_outlined},
    {'name': 'Web', 'icon': Icons.language_outlined},
    {'name': 'Hotline', 'icon': Icons.support_agent_outlined},
    {'name': 'Clock', 'icon': Icons.access_time_outlined},
    {'name': 'Social', 'icon': Icons.share_outlined},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().fetchContactDetails());
  }

  void _showAddContactDialog() {
    final labelController = TextEditingController();
    final valueController = TextEditingController();
    int selectedIconIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('Add Contact Detail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              const Text('Select Icon', style: TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIconIndex == index;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIconIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryGreen : AppTheme.bgGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _availableIcons[index]['icon'],
                          color: isSelected ? Colors.white : AppTheme.textGrey,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Label',
                  hintText: 'e.g., Customer Support Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: 'e.g., support@diesel.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppTheme.borderGrey),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (labelController.text.isEmpty || valueController.text.isEmpty) return;
                        
                        await context.read<DataProvider>().addContactDetail(
                          labelController.text,
                          valueController.text,
                          icon: _availableIcons[selectedIconIndex]['name'],
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Add Detail'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.info_outline;
    final found = _availableIcons.firstWhere((element) => element['name'] == iconName, orElse: () => _availableIcons.first);
    return found['icon'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        title: const Text('CONTACT DETAILS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          if (provider.isContactLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (provider.contactDetails.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.contact_mail_outlined, size: 64, color: AppTheme.textGrey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No contact details added yet', style: TextStyle(color: AppTheme.textGrey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddContactDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Contact Info'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.contactDetails.length,
            itemBuilder: (context, index) {
              final contact = provider.contactDetails[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIconData(contact.icon), color: AppTheme.primaryGreen, size: 20),
                  ),
                  title: Text(contact.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textGrey)),
                  subtitle: Text(contact.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                  trailing: IconButton(
                    onPressed: () => provider.deleteContactDetail(contact.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
