
class RecipeDetails {
  final String title;
  final String imageUrl;
  final int readyInMinutes;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;

  RecipeDetails({
    required this.title,
    required this.imageUrl,
    required this.readyInMinutes,
    required this.servings,
    required this.ingredients,
    required this.instructions,
  });

  factory RecipeDetails.fromJson(Map<String, dynamic> json) {
    // Extract ingredients
    final ingredientsList = (json['extendedIngredients'] as List)
        .map((ingredient) => ingredient['original'] as String)
        .toList();

    // Extract instructions
    List<String> instructionsList = [];
    if (json['analyzedInstructions'] != null && (json['analyzedInstructions'] as List).isNotEmpty) {
      final steps = (json['analyzedInstructions'][0]['steps'] as List);
      instructionsList = steps.map((step) => step['step'] as String).toList();
    } else if (json['instructions'] != null) {
      // Fallback for recipes with no analyzed instructions
      instructionsList = (json['instructions'] as String).split('\n');
    }

    return RecipeDetails(
      title: json['title'],
      imageUrl: json['image'],
      readyInMinutes: json['readyInMinutes'],
      servings: json['servings'],
      ingredients: ingredientsList,
      instructions: instructionsList,
    );
  }
}