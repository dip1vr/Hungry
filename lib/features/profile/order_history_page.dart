import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFFFF8C00);

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: kPrimaryColor,
      ),
      body: const Center(child: Text("Order History content here")),
    );
  }
}
