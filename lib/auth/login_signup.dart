import 'package:flutter/material.dart';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool isSignupScreen = false;
  bool isPasswordVisible = false;
  bool showInitialScreen = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void toggleFormMode() {
    setState(() {
      isSignupScreen = !isSignupScreen;
      emailController.clear();
      passwordController.clear();
      fullNameController.clear();
      confirmPasswordController.clear();
    });
  }

  void showSignInOrSignUpScreen(bool isSignup) {
    setState(() {
      showInitialScreen = false;
      isSignupScreen = isSignup;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor:
          isError ? const Color.fromARGB(255, 255, 209, 209) : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 100,
        left: 20,
        right: 20,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleSignUp() async {
    try {
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        _showSnackBar(
            'Sign up successful! Welcome, ${userCredential.user?.email}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(currentIndex: 1),
          ),
        );
      } else {
        _showSnackBar('Passwords do not match', isError: true);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Sign-up failed', isError: true);
    }
  }

  void _handleSignIn() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      _showSnackBar(
          'Sign in successful! Welcome back, ${userCredential.user?.email}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(currentIndex: 1),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Sign-in failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 118, 18, 18),
              Color.fromRGBO(173, 5, 5, 1),
              Color.fromARGB(255, 255, 110, 110),
            ],
          ),
        ),
        child: SafeArea(
          child: showInitialScreen
              ? _buildInitialScreen()
              : _buildSignInSignUpForm(),
        ),
      ),
    );
  }

  Widget _buildInitialScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_available,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 40),
          const Text(
            "HAPPENINGS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => showSignInOrSignUpScreen(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'SIGN IN',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => showSignInOrSignUpScreen(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'SIGN UP',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Login with Social Media',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook, color: Colors.white),
              SizedBox(width: 20),
              Icon(Icons.email, color: Colors.white),
              SizedBox(width: 20),
              Icon(Icons.reddit, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInSignUpForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              if (!isSignupScreen)
                const Text(
                  'Welcome Back\nSign in!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                const Text(
                  'Create\nYour Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 40),
              // if (isSignupScreen)
              //   TextField(
              //     controller: fullNameController,
              //     decoration: InputDecoration(
              //       filled: true,
              //       fillColor: Colors.white,
              //       labelText: 'Full Name',
              //       labelStyle: const TextStyle(
              //         color: Colors.black,
              //         fontWeight: FontWeight.w500,
              //       ),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       prefixIcon: const Icon(Icons.person),
              //     ),
              //   ),
              // const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
              ),
              if (isSignupScreen) const SizedBox(height: 20),
              if (isSignupScreen)
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              if (!isSignupScreen)
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Handle "Forgot Password" functionality
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 152, 10, 10),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (isSignupScreen) {
                        _handleSignUp();
                      } else {
                        _handleSignIn();
                      }
                    },
                    child: Text(
                      isSignupScreen ? 'SIGN UP' : 'SIGN IN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: toggleFormMode,
                  child: Text(
                    isSignupScreen
                        ? "Already have an account? Sign In"
                        : "Don't have an account? Sign Up",
                    style: const TextStyle(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
