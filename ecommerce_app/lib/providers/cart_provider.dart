import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }

  // factory CartItem.fromJson(Map<String, dynamic> json) {
  //   return CartItem(
  //     id: json['id'],
  //     name: json['name'],
  //     price: json['price'],
  //     quantity: json['quantity'],
  //   );
  // }
}







class CartProvider with ChangeNotifier {

  // 2. This is the private list of items.
  //    No one outside this class can access it directly.

  // final List<CartItem> _items = [];
  List<CartItem> _items = [];

// 3. A public "getter" to let widgets *read* the list of items
  List<CartItem> get items => _items;

  String? _userId; // Will hold the current user's ID
  StreamSubscription? _authSubscription; // To listen to auth changes

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // 4. A public "getter" to calculate the total number of items
  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
    // int total = 0;
    // for (var item in _items) {
    //   total += item.quantity;
    // }
    // return total;
  }

  // 5. A public "getter" to calculate the total price
  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  double get vat {
    return subtotal * 0.12; // 12% of the subtotal
  }

  double get totalPriceWithVat {
    return subtotal + vat;
  }





  // CartProvider() {
  //   print('CartProvider initialized');
  // // Listen to authentication changes
  //   _authSubscription = _auth.authStateChanges().listen((User? user) {
  //     if (user == null) {
  // // User is logged out
  //       print('User logged out, clearing cart.');
  //         _userId = null;
  //         _items = []; // Clear local cart
  //     } else {
  // // User is logged in
  //       print('User logged in: ${user.uid}. Fetching cart...');
  //         _userId = user.uid;
  //         _fetchCart(); // Load their cart from Firestore
  //     }
  // // Notify listeners to update UI (e.g., clear cart badge on logout)
  //     notifyListeners();
  //   });
  //
  //
  // }

  CartProvider() {
    print('CartProvider created.');
  }
  void initializeAuthListener() {
    print('CartProvider auth listener initialized');
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User logged out, clearing cart.');
        _userId = null;
        _items = [];
      } else {
        print('User logged in: ${user.uid}. Fetching cart...');
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }





  Future<void> _fetchCart() async {
    if (_userId == null) return; // Not logged in, nothing to fetch

    try {
// 1. Get the user's specific cart document
      final doc = await _firestore.collection('userCarts').doc(_userId).get();

      if (doc.exists && doc.data()!['cartItems'] != null) {
// 2. Get the list of items from the document
        final List<dynamic> cartData = doc.data()!['cartItems'];

// 3. Convert that list of Maps into our List<CartItem>
//    (This is why we made CartItem.fromJson!)
        _items = cartData.map((item) => CartItem.fromJson(item)).toList();
        print('Cart fetched successfully: ${_items.length} items');
      } else {
// 4. The user has no saved cart, start with an empty one
        _items = [];
      }
    } catch (e) {
      print('Error fetching cart: $e');
      _items = []; // On error, default to an empty cart
    }}
  notifyListeners();
  // Update the UI
  Future<void> _saveCart() async {
    if (_userId == null) return; // Not logged in, nowhere to save

    try {
// 1. Convert our List<CartItem> into a List<Map>
//    (This is why we made toJson()!)
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      // 2. Find the user's document and set the 'cartItems' field
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });

      print('Cart saved to Firestore');
    } catch (e) {
      print('Error saving cart: $e');
    }
  }





// 6. The main logic: "Add Item to Cart"
//   void addItem(String id, String name, double price) {
//     // 7. Check if the item is already in the cart
//     var index = _items.indexWhere((item) => item.id == id);
//
//     if (index != -1) {
//       // 8. If YES: just increase the quantity
//       _items[index].quantity++;
//     } else {
//       // 9. If NO: add it to the list as a new item
//       _items.add(CartItem(id: id, name: name, price: price));
//     }
//     _saveCart();
//     // 10. CRITICAL: This tells all "listening" widgets to rebuild!
//     notifyListeners();
//   }


  void addItem(String id, String name, double price, int quantity) {
    // 3. Check if the item is already in the cart
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      // 4. If YES: Add the new quantity to the existing quantity
      _items[index].quantity += quantity;
    } else {
      // 5. If NO: Add the item with the specified quantity
      _items.add(CartItem(
        id: id,
        name: name,
        price: price,
        quantity: quantity, // Use the quantity from the parameter
      ));
    }
    _saveCart(); // This is the same
    notifyListeners(); // This is the same
  }


  // 11. The "Remove Item from Cart" logic
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  Future<void> placeOrder() async {

    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      // 3. Convert our List<CartItem> to a List<Map> using toJson()
      final List<Map<String, dynamic>> cartData =
      _items.map((item) => item.toJson()).toList();

      // 4. Get total price and item count from our getters
      final double sub = subtotal;
      final double v = vat;
      final double total = totalPriceWithVat;
      final int count = itemCount;

      // 2. Update the data we save to Firestore
      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'subtotal': sub,       // 3. ADD THIS
        'vat': v,            // 4. ADD THIS
        'totalPrice': total,   // 5. This is now the VAT-inclusive price
        'itemCount': count,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });


      // 7. Note: We DO NOT clear the cart here.
      //    We'll call clearCart() separately from the UI after this succeeds.

    } catch (e) {
      print('Error placing order: $e');
      // 8. Re-throw the error so the UI can catch it
      throw e;
    }
  }


  // 9. ADD THIS: Clears the cart locally AND in Firestore
  Future<void> clearCart() async {
    // 10. Clear the local list
    _items = [];

    // 11. If logged in, clear the Firestore cart as well
    if (_userId != null) {
      try {
        // 12. Set the 'cartItems' field in their cart doc to an empty list
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        print('Firestore cart cleared.');
      } catch (e) {
        print('Error clearing Firestore cart: $e');
      }
    }

    // 13. Notify all listeners (this will clear the UI)
    notifyListeners();
  }





//   Future<void> _fetchCart() async {
//     if (_userId == null) return; // Not logged in, nothing to fetch
//
//     try {
// // 1. Get the user's specific cart document
//       final doc = await _firestore.collection('userCarts').doc(_userId).get();
//
//       if (doc.exists && doc.data()!['cartItems'] != null) {
// // 2. Get the list of items from the document
//         final List<dynamic> cartData = doc.data()!['cartItems'];
//
// // 3. Convert that list of Maps into our List<CartItem>
// //    (This is why we made CartItem.fromJson!)
//         _items = cartData.map((item) => CartItem.fromJson(item)).toList();
//         print('Cart fetched successfully: ${_items.length} items');
//     } else {
// // 4. The user has no saved cart, start with an empty one
//       _items = [];
//     }
//     } catch (e) {
//       print('Error fetching cart: $e');
//       _items = []; // On error, default to an empty cart
//   }}
//     notifyListeners(); // Update the UI
//   }
//     Future<void> _saveCart() async {
//       if (_userId == null) return; // Not logged in, nowhere to save
//
//       try {
// // 1. Convert our List<CartItem> into a List<Map>
// //    (This is why we made toJson()!)
//         final List<Map<String, dynamic>> cartData =
//           _items.map((item) => item.toJson()).toList();
//
//     // 2. Find the user's document and set the 'cartItems' field
//         await _firestore.collection('userCarts').doc(_userId).set({
//           'cartItems': cartData,
//         });
//         print('Cart saved to Firestore');
//       } catch (e) {
//         print('Error saving cart: $e');
//       }
//     }


  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel the auth listener
    super.dispose();
  }




}





