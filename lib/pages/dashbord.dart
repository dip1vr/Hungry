import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:hungry/pages/cartpage.dart';
import 'package:hungry/pages/orderUI.dart';
// Import CartPage

// Constants for reusability
const kPrimaryOrange = Color(0xFFFF8C00);
const kSecondaryOrange = Color(0xFFFF4E50);
const kCardWidth = 380.0;
const kSmallCardWidth = 180.0;
const kSmallCardHeight = 100.0;
const kImageHeight = 180.0;
const kOfferCardHeight = 220.0;
const kLightBlueBackground = Color.fromRGBO(135, 206, 250, 0.6);
const kGreenBackground = Color.fromRGBO(144, 238, 144, 0.9);
const kRedBackground = Color.fromRGBO(255, 245, 238, 0.9);
const kYellowBackground = Color.fromRGBO(255, 255, 224, 0.9);

// Reusable badge widget (unchanged)
class Badge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const Badge({
    super.key,
    required this.text,
    this.color = Colors.green,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable image card widget (unchanged)
class ImageCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ImageCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  color: Colors.black,
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable quick action card widget (unchanged)
class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final Color backgroundColor;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: kSmallCardWidth,
      height: kSmallCardHeight,
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable offer card widget (unchanged)
class OfferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String emoji;

  const OfferCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    this.emoji = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: 400,
        height: kOfferCardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.4),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (emoji.isNotEmpty) ...[
                Text(
                  emoji,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Claim Now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable restaurant card widget (unchanged)
class RestaurantCard extends StatelessWidget {
  final String name;
  final String category;
  final String imageUrl;
  final String deliveryTime;
  final double rating;

  const RestaurantCard({
    super.key,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.deliveryTime,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: kCardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  imageUrl,
                  height: kImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: Badge(text: "FREE Delivery", icon: Icons.local_shipping),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Badge(
                  text: rating.toString(),
                  color: Colors.white,
                  icon: Icons.star,
                ),
              ),
              const Positioned(
                bottom: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: kPrimaryOrange,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "🕜 $deliveryTime",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryOrange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Popular",
                        style: TextStyle(color: kPrimaryOrange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text(
                          "View Menu",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.favorite_border),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Dash extends StatelessWidget {
  const Dash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Midjourney.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section (unchanged)
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    image: DecorationImage(
                      image: AssetImage("assets/lime.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FoodJoy',
                                style: GoogleFonts.permanentMarker(
                                  textStyle: const TextStyle(
                                    color: kPrimaryOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              const Text(
                                "Premium Food Delivery",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.notifications_sharp,
                                  color: kPrimaryOrange,
                                  size: 25,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: kPrimaryOrange,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Hey Dip!\nHungry?",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                          children: const [
                            TextSpan(text: "Let's find something "),
                            TextSpan(
                              text: "delicious",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryOrange,
                              ),
                            ),
                            TextSpan(text: " for you!"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.green,
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "30-40\nmin",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.cyan,
                                ),
                                child: const Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "4.5+\nmin",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.purple[400]!,
                                ),
                                child: const Icon(
                                  Icons.delivery_dining,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Free\nDelivery",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search for food, restaurants",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [kPrimaryOrange, kSecondaryOrange],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // What's on Your Mind Section (unchanged)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "What's on your mind?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Trending 📈",
                        style: TextStyle(color: kPrimaryOrange, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: const [
                        ImageCard(
                          title: "Pizza",
                          imageUrl:
                              "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=781&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        ),
                        SizedBox(width: 16),
                        ImageCard(
                          title: "Burger",
                          imageUrl:
                              "https://images.unsplash.com/photo-1586190848861-99aa4a171e90?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        ),
                        SizedBox(width: 16),
                        ImageCard(
                          title: "Pasta",
                          imageUrl:
                              "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        ),
                        SizedBox(width: 16),
                        ImageCard(
                          title: "Salad",
                          imageUrl:
                              "https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=873&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        ),
                        SizedBox(width: 16),
                        ImageCard(
                          title: "Desert",
                          imageUrl:
                              "https://images.unsplash.com/photo-1551024506-0bccd828d307?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                        ),
                      ],
                    ),
                  ),
                ),
                // Quick Action Section (unchanged)
                const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    "Quick Action",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    QuickActionCard(
                      title: "Track Order",
                      subtitle: "Live Tracking",
                      icon: Icons.location_on_outlined,
                      gradientStart: Color(0xFF2193b0),
                      gradientEnd: Color(0xFF6dd5ed),
                      backgroundColor: kLightBlueBackground,
                    ),
                    QuickActionCard(
                      title: "Reorder",
                      subtitle: "Last Order",
                      icon: Icons.replay_outlined,
                      gradientStart: Color.fromARGB(255, 67, 224, 132),
                      gradientEnd: Color.fromARGB(255, 47, 157, 77),
                      backgroundColor: kGreenBackground,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    QuickActionCard(
                      title: "Favorites",
                      subtitle: "Your Picks",
                      icon: Icons.favorite,
                      gradientStart: Color.fromARGB(255, 231, 43, 43),
                      gradientEnd: Color.fromARGB(255, 251, 119, 119),
                      backgroundColor: kRedBackground,
                    ),
                    QuickActionCard(
                      title: "Offers",
                      subtitle: "Special Deals",
                      icon: Icons.card_giftcard_outlined,
                      gradientStart: Colors.orangeAccent,
                      gradientEnd: Colors.yellow,
                      backgroundColor: kYellowBackground,
                    ),
                  ],
                ),
                // Special Offers Section (unchanged)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Special Offers",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "✨ Limited Time",
                        style: TextStyle(color: kPrimaryOrange, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const OfferCard(
                  title: "50% OFF",
                  subtitle: "First Order",
                  description: "Get amazing discounts on your first order",
                  imageUrl:
                      "https://images.unsplash.com/photo-1695457209155-a5529f198218?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  emoji: "🎉",
                ),
                const OfferCard(
                  title: "Free Delivery",
                  subtitle: "Orders rs150+",
                  description: "No delivery fees on orders above 150 Rupees",
                  imageUrl:
                      "https://plus.unsplash.com/premium_photo-1678283974882-a00a67c542a9?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                ),
                // Popular Near You Section (unchanged)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Popular Near You",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "See All ->",
                        style: TextStyle(color: kPrimaryOrange, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("restaurants")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData == snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No Restaurants Available"),
                        );
                      }
                      final restaurants = snapshot.data!.docs;
                      return Row(
                        children: restaurants.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          return RestaurantCard(
                            name: data['restaurantName'] ?? "Unknown",
                            category: data['cuisineType'] ?? "No Category",
                            imageUrl:
                                data['imageUrl'] ??
                                "https://images.unsplash.com/photo-1504674900247-0877df9cc836",
                            deliveryTime: data['prepairTime'] ?? "20-30 min",
                            rating: (data['rating'] ?? 4.5).toDouble(),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Recommended For You ...",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Integrate FoodList here
                const FoodList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        final controller = Get.find<FoodController>();
        return controller.cartItems.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  Get.to(() => CartPage());
                },
                backgroundColor: Colors.green.withOpacity(0.9),
                label: Text(
                  "${controller.cartItems.length} Item${controller.cartItems.length > 1 ? 's' : ''} | ₹${controller.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
              )
            : const SizedBox.shrink();
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
