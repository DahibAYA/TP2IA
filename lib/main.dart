import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tp2/Screens/login.page.dart';
import 'package:tp2/Screens/home.page.dart';
import 'package:tp2/Screens/detail.page.dart';
import 'package:tp2/Screens/basket.page.dart';
import 'package:tp2/Screens/profile.page.dart';
import 'package:tp2/Screens/addclothingscreen.page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/details': (context) => DetailsPage(
              item: ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
            ),
        '/profile': (context) => const ProfilePage(),
        '/basket': (context) =>
            BasketPage(userId: FirebaseAuth.instance.currentUser!.uid),
        '/addclothingscreen': (context) => const AddClothingScreen(),
      },
    );
  }
}
