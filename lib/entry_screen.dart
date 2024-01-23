import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'controllers/budget_controller.dart';
import 'models/ModelProvider.dart';

class ManageBudgetEntryScreen extends ConsumerStatefulWidget {
  const ManageBudgetEntryScreen({required this.budgetEntry, super.key});
  final BudgetEntry? budgetEntry;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageBudgetEntryScreenState();
}

class _ManageBudgetEntryScreenState
    extends ConsumerState<ManageBudgetEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late final String _titleText;

  bool get _isCreate => _budgetEntry == null;
  BudgetEntry? get _budgetEntry => widget.budgetEntry;

  @override
  void initState() {
    super.initState();

    final budgetEntry = _budgetEntry;
    if (budgetEntry != null) {
      _titleController.text = budgetEntry.title;
      _descriptionController.text = budgetEntry.description ?? '';
      _amountController.text = budgetEntry.amount.toStringAsFixed(2);
      _titleText = 'Update budget entry';
    } else {
      _titleText = 'Create budget entry';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // If the form is valid, submit the data
    final title = _titleController.text;
    final description = _descriptionController.text;
    final amount = double.parse(_amountController.text);

    if (_isCreate) {
      ref.read(budgetNotifierProvider.notifier).createBudgetEntry(
            title: title,
            description: description,
            amount: amount,
          );
    } else {
      ref.read(budgetNotifierProvider.notifier).updateBudgetEntry(
            id: _budgetEntry!.id,
            title: title,
            description: description,
            amount: amount,
          );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleText),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title (required)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: false,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount (required)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (widget.budgetEntry != null)
                      Text(
                        'Oluşturulma Tarihi: ${widget.budgetEntry!.createdAt!.getDateTimeInUtc().toLocal().toString().split('.')[0]}',
                        style: const TextStyle(fontSize: 24),
                      ),
                    if (widget.budgetEntry != null)
                      Text(
                        'Güncellenme Tarihi: ${widget.budgetEntry!.updatedAt!.getDateTimeInUtc().toLocal().toString().split('.')[0]}',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ElevatedButton(
                      onPressed: submitForm,
                      child: Text(_titleText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
