// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:my_app/auth/login_signup.dart';

// class AccountPage extends StatelessWidget {
//   const AccountPage({super.key});

//   void _handleLogout(BuildContext context) async {
//     // Firebase sign out
//     await FirebaseAuth.instance.signOut();

//     // Navigate the user back to the login/signup page
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LoginSignupPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Account'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Account Page',
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//                 fontSize: 20,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _handleLogout(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).colorScheme.primary,
//                 padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//               ),
//               child: const Text(
//                 'Log Out',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Theme.of(context).colorScheme.surface,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/auth/login_signup.dart';
import 'package:my_app/event_model.dart';
import 'package:my_app/view_event_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User? user;
  List<Event> _myEvents = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchMyEvents(); // Fetch user's created events
  }

  Future<void> _fetchMyEvents() async {
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('creatorId', isEqualTo: user!.uid)
          .get();

      List<Event> events = querySnapshot.docs.map((doc) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      setState(() {
        _myEvents = events; // Store fetched events in the state
      });
    }
  }

  // Function to handle password change
  void _changePassword(BuildContext context) async {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // Show a dialog to input the new password and re-authenticate
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;
                String newPassword = newPasswordController.text;

                if (newPassword.isNotEmpty &&
                    email.isNotEmpty &&
                    password.isNotEmpty) {
                  try {
                    // Re-authenticate the user
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    // Update the password after successful re-authentication
                    await userCredential.user?.updatePassword(newPassword);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password updated successfully')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginSignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome, ${user?.email ?? 'User'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _changePassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'My Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _myEvents.isEmpty
                  ? const Text('No events created.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _myEvents.length,
                      itemBuilder: (context, index) {
                        final event = _myEvents[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewEventPage(event: event),
                              ),
                            );
                          },
                          child: EventCard(event: event),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final imagePath =
        event.imagePaths.isNotEmpty ? event.imagePaths.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        child: ListTile(
          leading: imagePath != null
              ? Image.network(imagePath, fit: BoxFit.cover, width: 60)
              : const Icon(Icons.event),
          title: Text(event.name),
          subtitle: Text(event.location),
        ),
      ),
    );
  }
}
