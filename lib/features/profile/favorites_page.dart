import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFFF8C00);

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: kPrimaryColor,
      ),
      body: const Center(child: Text("Favorites content here")),
    );
  }
}
