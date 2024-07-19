import 'package:farmnets/auth/auth_service_officer.dart';
import 'package:farmnets/screens/ext_officer/officer_home_screen.dart';
import 'package:farmnets/screens/farmer/farmer_auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farmnets/screens/ext_officer/officer_signup.dart';
import 'package:farmnets/widgets/form_container_widget.dart';
import 'package:farmnets/widgets/toast_widget.dart';

//import 'package:farmnets/themes/light_mode.dart';


class OfficerLogin extends StatefulWidget {
  const OfficerLogin({super.key});

  @override
  State<OfficerLogin> createState() => _OfficerLoginState();
}

class _OfficerLoginState extends State<OfficerLogin> {
  //final FirebaseAuthServiceOfficer _auth = FirebaseAuthServiceOfficer();
  final authService = AuthServiceOfficer();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.secondary,
          Colors.white,
        ],
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const FarmerAuthScreen()),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const Text(
                    'Please sign in to your account',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FormContainerWidget(
                          hintText: "Email",
                          isPasswordField: false,
                          controller: _emailController,
                        ),
                        const SizedBox(height: 10),
                        FormContainerWidget(
                          hintText: "Password",
                          isPasswordField: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: GestureDetector(
                            onTap: _signIn,
                            child: Container(
                              width: double.infinity,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  "SIGN IN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 34, 28, 28),
                                  fontSize: 15),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const OfficerSignUp()),
                                    (route) => false);
                              },
                              child: Text(
                                "SIGN UP",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isSigningIn)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Show loading circle
    setState(() {
      _isSigningIn = true;
    });

    // Show loading circle
    /*showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });*/

    UserCredential? result;
    try {
      result = await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        // Pop the loading circle
        //Navigator.of(context).pop();

        // Pop loading circle
        setState(() {
          _isSigningIn = false;
        });
      }
      showToast(message: "Failed to sign in: $e");
    }

    if (result == null) {
      if (mounted) {
        // Pop the loading circle
        /*Navigator.of(context).pop();*/
        showToast(message: 'Could not sign in');
      }
      // Pop loading circle
      setState(() {
        _isSigningIn = false;
      });
      return;
    }

    if (result.user != null) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const OfficerHomeScreen(),
            ),
            (route) => false);
      }
    }
  }
}
