import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ingredients/ingredients.dart';
import 'results_screen.dart';

//  State Management 
class PantryNotifier extends StateNotifier<List<String>> {
  PantryNotifier() : super([]);

  void addIngredient(String ingredient) {
    if (ingredient.isNotEmpty && !state.contains(ingredient)) {
      state = [...state, ingredient];
    }
  }

  void removeIngredient(String ingredient) {
    state = state.where((item) => item != ingredient).toList();
  }

  void clearAll() {
    state = [];
  }
}

final pantryProvider = StateNotifierProvider<PantryNotifier, List<String>>((ref) {
  return PantryNotifier();
});

// UI
class PantryScreen extends ConsumerWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIngredients = ref.watch(pantryProvider);
    final pantryNotifier = ref.read(pantryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
      ),
      body: Column(
        children: [
          // Display selected ingredients
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Ingredients',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (selectedIngredients.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => pantryNotifier.clearAll(),
                          icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                          label: const Text('Clear All'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (selectedIngredients.isEmpty)
                    const Text(
                      'Select ingredients from the list below.',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    )
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: selectedIngredients
                          .map((ingredient) => Chip(
                                label: Text(ingredient),
                                onDeleted: () => pantryNotifier.removeIngredient(ingredient),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          
          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              itemCount: categorizedIngredients.length,
              itemBuilder: (context, index) {
                final category = categorizedIngredients.keys.elementAt(index);
                final ingredients = categorizedIngredients[category]!;
                return ExpansionTile(
                  title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: ingredients.map((ingredient) {
                          final isSelected = selectedIngredients.contains(ingredient);
                          return FilterChip(
                            label: Text(ingredient),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              if (selected) {
                                pantryNotifier.addIngredient(ingredient);
                              } else {
                                pantryNotifier.removeIngredient(ingredient);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: selectedIngredients.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsScreen(ingredients: selectedIngredients),
                        ),
                      );
                    },
              child: const Text('Find Recipes', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}