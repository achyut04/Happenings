import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/firebase_options.dart';
import 'add_event_page.dart';
import 'home_page.dart';
import 'account_page.dart';
import './auth/login_signup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? user = FirebaseAuth.instance.currentUser;

  runApp(
    MyApp(
        initialScreen: user == null
            ? const LoginSignupPage()
            : const MainScreen(currentIndex: 1)),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(173, 5, 5, 1),
          primary: const Color.fromRGBO(173, 5, 5, 1),
          onPrimary: Colors.white,
          secondary: const Color.fromRGBO(214, 214, 214, 1),
          onSecondary: Colors.black,
          background: const Color.fromARGB(255, 247, 247, 247),
          surface: const Color.fromARGB(255, 255, 255, 255),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(173, 5, 5, 1),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 214, 214, 214),
          selectedItemColor: Color.fromRGBO(173, 5, 5, 1),
          unselectedItemColor: Colors.black,
        ),
        cardColor: Colors.white,
        scaffoldBackgroundColor: const Color.fromARGB(255, 247, 247, 247),
      ),
      home: initialScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final int currentIndex;

  const MainScreen({super.key, required this.currentIndex});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginSignupPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: widget.currentIndex,
        children: const [
          AddEventPage(),
          HomePage(),
          AccountPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: widget.currentIndex,
        onTap: (index) {
          if (index != widget.currentIndex) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(currentIndex: index),
              ),
            );
          }
        },
      ),
    );
  }
}
