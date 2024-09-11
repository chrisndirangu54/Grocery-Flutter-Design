import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './screens/home_screen.dart'; // Import HomeScreen from a separate file
import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/loading_screen.dart'; // Ensure LoadingScreen is imported
import './screens/password_retrieval_screen.dart';
import './screens/offers_page.dart';
import './providers/auth_provider.dart';
import './providers/product_provider.dart';
import './providers/cart_provider.dart';
import './providers/offer_provider.dart';
import './providers/user_provider.dart';
import './providers/order_provider.dart'; // Added OrderProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle Firebase initialization with error handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get user => null;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(
            create: (_) => OrderProvider()), // Added OrderProvider
        ChangeNotifierProvider(
            create: (_) => UserProvider(name: '', email: '', user: user)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF1B1B1B),
          primaryColor: Colors.orangeAccent,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFFF5F5F5),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B1B1B),
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'Comfortaa',
            ),
            titleLarge: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Comfortaa',
            ),
          ),
        ),
        home: const LoadingScreen(), // Reference the LoadingScreen here
        routes: {
          '/home': (ctx) => const HomeScreen(),
          '/login': (ctx) => LoginScreen(),
          '/register': (ctx) => const RegisterScreen(),
          '/password-retrieval': (ctx) => const PasswordRetrievalScreen(),
          '/offers': (ctx) => const OffersPage(),
        },
      ),
    );
  }
}
