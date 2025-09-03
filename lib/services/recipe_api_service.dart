import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../secrets.dart'; 
import '../models/recipe_details.dart';

class RecipeApiService {
  Future<List<Recipe>> findRecipesByIngredients(List<String> ingredients) async {
    final String ingredientsString = ingredients.join(', ');
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredientsString&number=10&ranking=2&apiKey=$spoonacularApiKey'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } else {

        print('API call failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      throw Exception('Failed to load recipes');
    }
  }

Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/$recipeId/information?includeNutrition=false&apiKey=$spoonacularApiKey'
    );
    
    print('Requesting Details URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RecipeDetails.fromJson(data);
      } else {
        throw Exception('Failed to load recipe details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}