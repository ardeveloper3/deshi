import 'package:flutter/material.dart';

class AddTestRowScreen extends StatefulWidget {
  const AddTestRowScreen({super.key});

  @override
  State<AddTestRowScreen> createState() => _AddTestRowScreenState();
}

class _AddTestRowScreenState extends State<AddTestRowScreen> {
  final _titleController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন তথ্য')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'নতুন তথ্য যোগ করুন',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'প্রয়োজনীয় তথ্য লিখে সংরক্ষণ করুন।',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'শিরোনাম',
                    hintText: 'যেমন: দেশি মুরগি',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: const Text('সংরক্ষণ করুন'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
