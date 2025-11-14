import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';

import 'package:ecommerce_app/widgets/product_card.dart';

import 'package:ecommerce_app/screens/product_detail_screen.dart';

import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';

import 'package:ecommerce_app/screens/order_history_screen.dart';
import 'package:ecommerce_app/screens/profile_screen.dart';

import 'package:ecommerce_app/widgets/notification_icon.dart';

import 'package:ecommerce_app/screens/chat_screen.dart';
import 'package:ecommerce_app/main.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _userRole = 'user';

  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _fetchUserRole();
  }


  Future<void> _fetchUserRole() async {

    if (_currentUser == null) return;
    try {

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc.data()!['role'];
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        backgroundColor: topbarBGC,


        // title: Text(_currentUser != null ? 'Welcome, ${_currentUser!.email}' : 'Home',
        //   style: const TextStyle(color: Colors.white),
        // ),

        title: Image.asset(
          'assets/images/splash_logo.png', // 3. The path to your logo
          height: 40, // 4. Set a fixed height
        ),

        actions: [

          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge(
                backgroundColor: Colors.blue,
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  tooltip: 'My Cart',
                  color: Colors.white,
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),



          // Consumer<CartProvider>(
          //   builder: (context, cart, child) {
          //     return Badge(
          //       backgroundColor: Colors.black87,
          //       label: Text(cart.itemCount.toString()),
          //       isLabelVisible: cart.itemCount > 0,
          //       child: IconButton(
          //         color: Colors.white,
          //         icon: const Icon(Icons.shopping_cart),
          //         onPressed: () {
          //           Navigator.of(context).push(
          //             MaterialPageRoute(
          //               builder: (context) => const CartScreen(),
          //             ),
          //           );
          //         },
          //       ),
          //     );
          //   },
          // ),

          const NotificationIcon(),

          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),



          if (_userRole == 'admin')
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),


        //   IconButton(
        //     color: Colors.white,
        //     icon: const Icon(Icons.logout),
        //     tooltip: 'Logout',
        //     onPressed: _signOut,
        //   ),
        // ],

        IconButton(
            color: Colors.white,
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            }
        ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),

            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;

              return ProductCard(

                productName: productData['name'],
                price: (productData['price'] as num).toDouble(),
                // price: productData['price'],
                imageUrl: productData['imageUrl'],

                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productData: productData,
                        productId: productDoc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>( // 2. A new StreamBuilder
        // 3. Listen to *this user's* chat document
        stream: _firestore.collection('chats').doc(_currentUser!.uid).snapshots(),
        builder: (context, snapshot) {

          int unreadCount = 0;
          // 4. Check if the doc exists and has our count field
          if (snapshot.hasData && snapshot.data!.exists) {
            // Ensure data is not null before casting
            final data = snapshot.data!.data();
            if (data != null) {
              unreadCount = (data as Map<String, dynamic>)['unreadByUserCount'] ?? 0;
            }
          }

          // 5. --- THE FIX for "trailing not defined" ---
          //    We wrap the FAB in the Badge widget
          return Badge(
            backgroundColor: Colors.blue,
            // 6. Show the count in the badge
            label: Text('$unreadCount'),
            // 7. Only show the badge if the count is > 0
            isLabelVisible: unreadCount > 0,
            // 8. The FAB is now the *child* of the Badge
            child: FloatingActionButton.extended(

              backgroundColor: Colors.red[900],
              icon: const Icon(Icons.support_agent,
              color: Colors.white,),
              label: const Text('Contact Admin',
                style: TextStyle(
                  color: Colors.white
                )),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatRoomId: _currentUser!.uid,
                    ),
                  ),
                );
              },
            ),
          );
          // --- END OF FIX ---
        },
      )
          : null, // 9. If admin, don't show the FAB
    );
  }
}

