import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/payment_account_model.dart';
import '../core/app_theme.dart';

class PaymentAccountsScreen extends StatefulWidget {
  const PaymentAccountsScreen({super.key});

  @override
  State<PaymentAccountsScreen> createState() => _PaymentAccountsScreenState();
}

class _PaymentAccountsScreenState extends State<PaymentAccountsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ibanController = TextEditingController();

  void _showAddAccountDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _accountNameController,
                  decoration: const InputDecoration(labelText: 'Account Name (e.g. Meezan Bank)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _holderNameController,
                  decoration: const InputDecoration(labelText: 'Account Holder Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(labelText: 'Account Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ibanController,
                  decoration: const InputDecoration(labelText: 'IBAN (Optional)'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final account = PaymentAccount(
                        id: '',
                        accountName: _accountNameController.text,
                        holderName: _holderNameController.text,
                        accountNumber: _accountNumberController.text,
                        iban: _ibanController.text,
                      );
                      await context.read<DataProvider>().addPaymentAccount(account);
                      if (mounted) {
                        Navigator.pop(context);
                        _accountNameController.clear();
                        _holderNameController.clear();
                        _accountNumberController.clear();
                        _ibanController.clear();
                      }
                    }
                  },
                  child: const Text('Save Account'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment Accounts'),
        actions: [
          IconButton(
            onPressed: _showAddAccountDialog,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: data.isPaymentAccountsLoading
          ? const Center(child: CircularProgressIndicator())
          : data.paymentAccounts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No payment accounts added', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showAddAccountDialog,
                        child: const Text('Add First Account'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: data.paymentAccounts.length,
                  itemBuilder: (context, index) {
                    final account = data.paymentAccounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.account_balance_rounded, color: AppTheme.primaryGreen),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.accountName.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        account.holderName,
                                        style: const TextStyle(
                                          color: AppTheme.textGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(account.id),
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            _buildInfoRow(Icons.numbers_rounded, 'Account Number', account.accountNumber),
                            if (account.iban != null && account.iban!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.vpn_key_outlined, 'IBAN', account.iban!),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppTheme.textGrey, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This account will no longer be visible to users for online payments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<DataProvider>().deletePaymentAccount(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
