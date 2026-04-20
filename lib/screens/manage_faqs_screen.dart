import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';
import '../models/support_models.dart';

class ManageFaqsScreen extends StatefulWidget {
  const ManageFaqsScreen({super.key});

  @override
  State<ManageFaqsScreen> createState() => _ManageFaqsScreenState();
}

class _ManageFaqsScreenState extends State<ManageFaqsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().fetchFaqs());
  }

  void _showAddEditFaqDialog([Faq? faq]) {
    final questionController = TextEditingController(text: faq?.question);
    final answerController = TextEditingController(text: faq?.answer);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            Text(
              faq == null ? 'Add New FAQ' : 'Edit FAQ',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                hintText: 'e.g., What is your delivery time?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppTheme.bgGrey,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Answer',
                hintText: 'e.g., We deliver within 2-3 business days.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppTheme.bgGrey,
              ),
              maxLines: 4,
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
                      if (questionController.text.isEmpty || answerController.text.isEmpty) return;
                      
                      final provider = context.read<DataProvider>();
                      if (faq == null) {
                        await provider.addFaq(questionController.text, answerController.text);
                      } else {
                        await provider.updateFaq(faq.id, questionController.text, answerController.text);
                      }
                      if (mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(faq == null ? 'Add Question' : 'Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        title: const Text('MANAGE FAQS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, child) {
          if (provider.isFaqsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (provider.faqs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: AppTheme.textGrey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No FAQs added yet', style: TextStyle(color: AppTheme.textGrey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditFaqDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First FAQ'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.faqs.length,
            itemBuilder: (context, index) {
              final faq = provider.faqs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
                ),
                child: ExpansionTile(
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    faq.question,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            faq.answer,
                            style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => provider.deleteFaq(faq.id),
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                label: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _showAddEditFaqDialog(faq),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text('Edit'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditFaqDialog(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
