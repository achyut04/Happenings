import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_app/event_model.dart';
import 'package:my_app/firebase_options.dart';
import 'package:my_app/notificationspage.dart';
import 'add_event_page.dart';
import 'home_page.dart';
import 'account_page.dart';
import './auth/login_signup.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  User? user = FirebaseAuth.instance.currentUser;

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  Workmanager().registerPeriodicTask(
    "1",
    "checkUpcomingEvents",
    frequency: Duration(minutes: 15),
  );

  await requestNotificationPermission();

  runApp(
    MyApp(
        initialScreen: user == null
            ? const LoginSignupPage()
            : const MainScreen(currentIndex: 1)),
  );
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
            .collection('events')
            .where('registeredUsers', arrayContains: user.uid)
            .get();

        final currentTime = DateTime.now();
        for (var doc in eventSnapshot.docs) {
          final event =
              Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          DateTime eventTime = DateTime.parse(event.date + ' ' + event.time);
          Duration difference = eventTime.difference(currentTime);

          if (difference.inMinutes > 0 && difference.inMinutes <= 60) {
            await showNotification(event);
          }
        }
      }
    } catch (e) {
      print('Error in callbackDispatcher: $e');
    }

    return Future.value(true);
  });
}

Future<void> showNotification(Event event) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'event_channel',
    'Event Notifications',
    channelDescription: 'Notifications about upcoming events',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Upcoming Event: ${event.name}',
    'Event at ${event.time} is starting soon!',
    platformChannelSpecifics,
  );
  await saveNotificationToFirestore(
    'Upcoming Event: ${event.name}',
    'Event at ${event.time} is starting soon!',
  );
}

Future<void> saveNotificationToFirestore(String title, String body) async {
  await FirebaseFirestore.instance.collection('notifications').add({
    'title': title,
    'body': body,
    'timestamp': DateTime.now(),
  });
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isGranted) {
    print('Notification permission granted');
  } else {
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permission granted');
    } else if (status.isDenied || status.isPermanentlyDenied) {
      print('Notification permission denied');
    }
  }
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
          NotificationsPage(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
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
