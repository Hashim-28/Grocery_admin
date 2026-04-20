import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';

class DeliverySettingsScreen extends StatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  State<DeliverySettingsScreen> createState() => _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState extends State<DeliverySettingsScreen> {
  bool _isLoading = true;

  // Delivery config values
  double _standardCharge = 80;
  double _expressCharge = 150;
  double _freeAboveAmount = 5000;
  String _standardEta = '2-3 days';
  String _expressEta = 'Same day';
  bool _expressEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = context.read<DataProvider>();
    final config = await data.fetchDeliveryConfig();
    if (config != null && mounted) {
      setState(() {
        _standardCharge = (config['standard_charge'] ?? 80).toDouble();
        _expressCharge = (config['express_charge'] ?? 150).toDouble();
        _freeAboveAmount = (config['free_above_amount'] ?? 5000).toDouble();
        _standardEta = config['standard_eta'] ?? '2-3 days';
        _expressEta = config['express_eta'] ?? 'Same day';
        _expressEnabled = config['express_enabled'] ?? true;
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _updateField(String field, dynamic value) async {
    final data = context.read<DataProvider>();
    try {
      await data.updateDeliveryConfig(field, value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Updated successfully'),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    }
  }

  void _showAmountEditor({
    required String title,
    required String subtitle,
    required double currentValue,
    required String field,
    required Function(double) onSaved,
  }) {
    final controller = TextEditingController(text: currentValue.toInt().toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Amount (₨)',
                  prefixIcon: const Icon(Icons.currency_exchange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        side: const BorderSide(color: AppTheme.borderGrey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final val = double.tryParse(controller.text) ?? currentValue;
                        onSaved(val);
                        await _updateField(field, val);
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTextEditor({
    required String title,
    required String subtitle,
    required String currentValue,
    required String field,
    required String label,
    required Function(String) onSaved,
  }) {
    final controller = TextEditingController(text: currentValue);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: const Icon(Icons.schedule),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        side: const BorderSide(color: AppTheme.borderGrey),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final val = controller.text.trim();
                        if (val.isNotEmpty) {
                          onSaved(val);
                          await _updateField(field, val);
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        title: const Column(
          children: [
            Text('DELIVERY SETTINGS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Text('DIESEL CASH & CARRY', style: TextStyle(fontSize: 9, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_shipping_outlined, color: AppTheme.accentGreen, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery Configuration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 4),
                              Text('Manage delivery charges & options', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Standard Delivery Section ────────────────────────────
                  _SectionLabel(title: 'STANDARD DELIVERY', icon: Icons.inventory_2_outlined),
                  const SizedBox(height: 12),
                  _ConfigTile(
                    icon: Icons.payments_outlined,
                    label: 'Delivery Charge',
                    value: '₨${_standardCharge.toInt()}',
                    subtitle: 'Standard delivery fee',
                    onTap: () => _showAmountEditor(
                      title: 'Standard Delivery Charge',
                      subtitle: 'Amount charged for standard delivery',
                      currentValue: _standardCharge,
                      field: 'standard_charge',
                      onSaved: (val) => setState(() => _standardCharge = val),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ConfigTile(
                    icon: Icons.schedule,
                    label: 'Estimated Time',
                    value: _standardEta,
                    subtitle: 'Delivery ETA for customers',
                    onTap: () => _showTextEditor(
                      title: 'Standard Delivery ETA',
                      subtitle: 'Estimated delivery time shown to customers',
                      currentValue: _standardEta,
                      field: 'standard_eta',
                      label: 'ETA (e.g. 2-3 days)',
                      onSaved: (val) => setState(() => _standardEta = val),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Express Delivery Section ─────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SectionLabel(title: 'EXPRESS DELIVERY', icon: Icons.rocket_launch_outlined),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _expressEnabled,
                          onChanged: (val) async {
                            setState(() => _expressEnabled = val);
                            await _updateField('express_enabled', val);
                          },
                          activeColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedOpacity(
                    opacity: _expressEnabled ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_expressEnabled,
                      child: Column(
                        children: [
                          _ConfigTile(
                            icon: Icons.bolt,
                            label: 'Express Charge',
                            value: '₨${_expressCharge.toInt()}',
                            subtitle: 'Premium delivery fee',
                            iconColor: Colors.orange,
                            onTap: () => _showAmountEditor(
                              title: 'Express Delivery Charge',
                              subtitle: 'Amount charged for express/same-day delivery',
                              currentValue: _expressCharge,
                              field: 'express_charge',
                              onSaved: (val) => setState(() => _expressCharge = val),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _ConfigTile(
                            icon: Icons.timer_outlined,
                            label: 'Express ETA',
                            value: _expressEta,
                            subtitle: 'Express delivery time',
                            iconColor: Colors.orange,
                            onTap: () => _showTextEditor(
                              title: 'Express Delivery ETA',
                              subtitle: 'Estimated express delivery time',
                              currentValue: _expressEta,
                              field: 'express_eta',
                              label: 'ETA (e.g. Same day)',
                              onSaved: (val) => setState(() => _expressEta = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ─── Free Delivery Section ────────────────────────────────
                  _SectionLabel(title: 'FREE DELIVERY THRESHOLD', icon: Icons.card_giftcard_outlined),
                  const SizedBox(height: 12),
                  _ConfigTile(
                    icon: Icons.money_off,
                    label: 'Free Delivery Above',
                    value: '₨${_freeAboveAmount.toInt()}',
                    subtitle: 'No delivery charges above this amount',
                    iconColor: AppTheme.accentGreen,
                    onTap: () => _showAmountEditor(
                      title: 'Free Delivery Threshold',
                      subtitle: 'Orders above this amount get free delivery',
                      currentValue: _freeAboveAmount,
                      field: 'free_above_amount',
                      onSaved: (val) => setState(() => _freeAboveAmount = val),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.15)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Changes are applied immediately and will affect all new orders placed by customers.',
                            style: TextStyle(color: AppTheme.textGrey, fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ─── Section Label Widget ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionLabel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ],
    );
  }
}

// ─── Config Tile Widget ───────────────────────────────────────────────────────

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ConfigTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primaryGreen).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor ?? AppTheme.primaryGreen, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, color: AppTheme.borderGrey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
