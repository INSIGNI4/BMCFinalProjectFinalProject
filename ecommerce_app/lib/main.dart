import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/foundation.dart';

const Color kBrown = Color(0xFFB30B0B);      // Our main "coffee" brown
const Color kLightBrown = Color(0xFFD2B48C);  // A lighter tan/beige
const Color kOffWhite = Color(0xFFF8F4F0); //A warm, off-white background
const Color topbarBGC = Color(0xFFB30B0B);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(
            create: (_) {
              final cartProvider = CartProvider();
              cartProvider.initializeAuthListener();
              return cartProvider;
            },
          ),
        ],
        child: MyApp(),
      ),
    );
  } catch (e, stack) {
    print('Initialization error: $e');
    print(stack);
    runApp( MyApp());
  } finally {
    FlutterNativeSplash.remove();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eCommerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrown,
          brightness: Brightness.light,
          primary: kBrown,
          onPrimary: Colors.white,
          secondary: kLightBrown,
          background: kOffWhite,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: kOffWhite,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          labelStyle: TextStyle(color: kBrown.withOpacity(0.8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBrown, width: 2.0),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: AuthWrapper(),
    );
  }
}
