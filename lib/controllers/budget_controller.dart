// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:example_project/models/BudgetEntry.dart';

enum Status { loading, success, fail }

class BudgetState {
  final List<BudgetEntry?> budgets;
  final Status? status;
  final String? error;
  BudgetState({
    required this.budgets,
    this.status,
    this.error,
  });

  BudgetState copyWith({
    List<BudgetEntry?>? budgets,
    Status? status,
    String? error,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  String toString() =>
      'BudgetState(budgets: $budgets, status: $status, error: $error)';
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((final ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier()
      : super(
          BudgetState(
            budgets: [],
          ),
        ) {
    debugPrint("TodoNotifier initialized");
    getBudgets();
  }

  Future getBudgets() async {
    state = state.copyWith(status: Status.loading);
    final request = ModelQueries.list(BudgetEntry.classType);
    final response = await Amplify.API.query(request: request).response;
    if (response.hasErrors) {
      debugPrint(response.errors.toString());
      state = state.copyWith(status: Status.fail);
    } else {
      if (response.data != null) {
        state = state.copyWith(
          budgets: response.data!.items,
          status: Status.success,
        );
      }
    }
  }

  Future<void> createBudgetEntry(
      {required String title, description, required amount}) async {
    final newEntry = BudgetEntry(
      title: title,
      description: description.isNotEmpty ? description : null,
      amount: amount,
    );
    final request = ModelMutations.create(newEntry);
    final response = await Amplify.API.mutate(request: request).response;
    debugPrint('Create result: $response');
    await getBudgets();
  }

  Future<void> updateBudgetEntry(
      {required id,
      required String title,
      description,
      required amount}) async {
    final request = ModelMutations.update(
        state.budgets.firstWhere((element) => element!.id == id)!.copyWith(
              title: title,
              description: description.isNotEmpty ? description : null,
              amount: amount,
            ));
    final response = await Amplify.API.mutate(request: request).response;
    safePrint('Update result: $response');
    await getBudgets();
  }

  Future<void> deleteBudgetEntry(budgetId) async {
    final request = ModelMutations.deleteById(
        BudgetEntry.classType, BudgetEntryModelIdentifier(id: budgetId));

    final response = await Amplify.API.mutate(request: request).response;
    safePrint('Delete response: $response');
    await getBudgets();
  }
}
