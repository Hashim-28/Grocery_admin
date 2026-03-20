import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';

class ManageStaffScreen extends StatelessWidget {
  const ManageStaffScreen({super.key});

  void _showStaffForm(BuildContext context, {Staff? staff}) {
    final data = context.read<DataProvider>();
    final nameController = TextEditingController(text: staff?.name ?? '');
    String selectedRole = staff?.role ?? 'Staff Member';
    String selectedStatus = staff?.status ?? 'Active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(staff == null ? 'Add New Staff' : 'Edit Staff Details', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (staff != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            data.deleteStaff(staff.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff member removed')));
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(controller: nameController, decoration: const InputDecoration(hintText: 'e.g. Zaid Ahmed')),
                  const SizedBox(height: 20),
                  const Text('Assign Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: ['Staff Member', 'Admin', 'Manager']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedRole = v!),
                  ),
                  const SizedBox(height: 20),
                  if (staff != null) ...[
                    const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: ['Active', 'Offline', 'Suspended']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setModalState(() => selectedStatus = v!),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        if (staff == null) {
                          data.addStaff(nameController.text, selectedRole);
                        } else {
                          data.updateStaff(staff.id, nameController.text, selectedRole, selectedStatus);
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(staff == null ? 'Staff added' : 'Updated successfully')),
                        );
                      }
                    },
                    child: Text(staff == null ? 'Create Member' : 'Save Changes'),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        title: const Text('Staff Management'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.staff.length,
        itemBuilder: (context, index) {
          final member = data.staff[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: ListTile(
              onTap: () => _showStaffForm(context, staff: member),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Text(member.name[0], style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
              ),
              title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(member.role, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(member.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      member.status,
                      style: TextStyle(
                        color: _getStatusColor(member.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textGrey),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStaffForm(context),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Offline': return Colors.grey;
      case 'Suspended': return Colors.red;
      default: return Colors.grey;
    }
  }
}
