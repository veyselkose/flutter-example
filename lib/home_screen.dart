import 'package:example_project/controllers/budget_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/ModelProvider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateToBudgetEntry({BudgetEntry? budgetEntry}) async {
    await context.pushNamed('manage', extra: budgetEntry);
  }

  double _calculateTotalBudget(List<BudgetEntry?> items) {
    var totalAmount = 0.0;
    for (final item in items) {
      totalAmount += item?.amount ?? 0;
    }
    return totalAmount;
  }

  Widget _buildRow({
    required String title,
    required String description,
    required String amount,
    TextStyle? style,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        Expanded(
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        Expanded(
          child: Text(
            amount,
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // Navigate to the page to create new budget entries
        onPressed: _navigateToBudgetEntry,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Budget Tracker'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(budgetNotifierProvider.notifier).getBudgets();
            },
            child: Consumer(builder: (context, WidgetRef ref, _) {
              final budgetState = ref.watch(budgetNotifierProvider);
              // final todoNotifier = ref.read(budgetNotifierProvider.notifier);
              if (budgetState.budgets.isEmpty &&
                  budgetState.status != Status.loading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Empty"),
                );
              } else if (budgetState.status == Status.loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (budgetState.status == Status.fail) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Error"),
                );
              } else {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Show total budget from the list of all BudgetEntries
                        Text(
                          'Total Budget: \$ ${_calculateTotalBudget(budgetState.budgets).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildRow(
                      title: 'Title',
                      description: 'Description',
                      amount: 'Amount',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: budgetState.budgets.length,
                        itemBuilder: (context, index) {
                          final budgetEntry = budgetState.budgets[index];
                          return Dismissible(
                            key: ValueKey(budgetEntry),
                            background: const ColoredBox(
                              color: Colors.red,
                              child: Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child:
                                      Icon(Icons.delete, color: Colors.white),
                                ),
                              ),
                            ),
                            onDismissed: (_) => ref
                                .read(budgetNotifierProvider.notifier)
                                .deleteBudgetEntry(
                                    budgetState.budgets[index]!.id),
                            child: ListTile(
                              onTap: () => _navigateToBudgetEntry(
                                budgetEntry: budgetState.budgets[index],
                              ),
                              title: _buildRow(
                                title: budgetState.budgets[index]!.title,
                                description:
                                    budgetState.budgets[index]!.description ??
                                        '',
                                amount:
                                    '\$ ${budgetState.budgets[index]!.amount.toStringAsFixed(2)}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            }),
          ),
        ),
      ),
    );
  }
}
