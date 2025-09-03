import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/recipe_details.dart';
import '../services/recipe_api_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailsScreen({super.key, required this.recipeId});

  @override
  RecipeDetailsScreenState createState() => RecipeDetailsScreenState();
}

class RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late Future<RecipeDetails> _detailsFuture;
  final RecipeApiService _apiService = RecipeApiService();

  @override
  void initState() {
    super.initState();
    _detailsFuture = _apiService.getRecipeDetails(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<RecipeDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Recipe not found.'));
          } else {
            final details = snapshot.data!;
            return CustomScrollView(
              slivers: [
                // Collapsing App Bar with the image
                SliverAppBar(
                  expandedHeight: 250.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(details.title, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 2.0)])),
                    background: CachedNetworkImage(
                      imageUrl: details.imageUrl,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.3),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Time and Servings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoChip(Icons.timer, '${details.readyInMinutes} min'),
                              _buildInfoChip(Icons.people, '${details.servings} servings'),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Ingredients Section
                          _buildSectionTitle('Ingredients'),
                          ...details.ingredients.map((ingredient) => ListTile(
                            leading: const Icon(Icons.check_box_outline_blank, size: 20),
                            title: Text(ingredient),
                          )),
                          const SizedBox(height: 20),

                          // Instructions Section
                          _buildSectionTitle('Instructions'),
                          ...List.generate(details.instructions.length, (index) {
                            return ListTile(
                              leading: CircleAvatar(child: Text('${index + 1}')),
                              title: Text(details.instructions[index]),
                            );
                          }),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon),
      label: Text(label),
    );
  }
}