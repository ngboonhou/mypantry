import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_api_service.dart';
import '../widget/recipe_card.dart';
import 'recipe_details_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<String> ingredients;

  const ResultsScreen({super.key, required this.ingredients});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  // A variable to hold the future result of the API call
  late final Future<List<Recipe>> _recipeFuture;
  final RecipeApiService _apiService = RecipeApiService();

  @override
  void initState() {
    super.initState();
    // Start the API call
    _recipeFuture = _apiService.findRecipesByIngredients(widget.ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Suggestions'),
        elevation: 2.0,
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          // Loading indicator 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Display error if API call failed
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'An error occurred: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // If API call succeeded but returned no recipes
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No recipes found. Try selecting different ingredients.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // If API call was successful and returned recipes
          final recipes = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two cards per row
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.8, 
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to the full recipe details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailsScreen(recipeId: recipe.id),
                    ),
                  );
                },
                child: RecipeCard(recipe: recipe),
              );
            },
          );
        },
      ),
    );
  }
}