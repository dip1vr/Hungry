import 'package:get/get.dart';

class FoodController extends GetxController {
  RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  void addToCart(Map<String, dynamic> foodItem) {
    final existingItemIndex = cartItems.indexWhere(
      (item) =>
          item["title"] == foodItem["title"] &&
          item["vendorId"] == foodItem["vendorId"],
    );
    if (existingItemIndex != -1) {
      cartItems[existingItemIndex]["quantity"]++;
      cartItems.refresh();
    } else {
      cartItems.add(foodItem);
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      cartItems[index]["quantity"] = newQuantity;
      cartItems.refresh();
    } else {
      cartItems.removeAt(index);
    }
  }

  double get totalPrice => cartItems.fold(
    0,
    (sum, item) => sum + (item["price"] * item["quantity"]),
  );
}
