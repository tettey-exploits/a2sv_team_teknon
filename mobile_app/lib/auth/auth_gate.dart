import 'dart:developer';

import 'package:farmnets/screens/farmer/farmer_auth_screen.dart';
import 'package:farmnets/screens/farmer/farmer_home_screen.dart';
import 'package:farmnets/screens/ext_officer/officer_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmnets/providers/user_provider.dart';
//import 'package:farmnets/screens/farmer/farmer_authentication.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator if the authentication state is still loading
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // User is signed in
            final user = FirebaseAuth.instance.currentUser!;
            final userProvider =
                Provider.of<UserProvider>(context, listen: false);

            /// update the UserProvider with the email or phone number of the
            /// user after the authentication state changes.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (user.email != null && user.email!.isNotEmpty) {
                // Extension officer
                log("Email: ${user.email}");
                userProvider.setEmail(user.email!);
              } else if (user.phoneNumber != null &&
                  user.phoneNumber!.isNotEmpty) {
                // Farmer
                log("Phone number: ${user.phoneNumber}");
                userProvider.setUsername(user.phoneNumber!);
              }
            });

            if (user.email != null && user.email!.isNotEmpty) {
              // Extension officer
              log("Email: ${user.email}");
              return const OfficerHomeScreen();
            } else if (user.phoneNumber != null &&
                user.phoneNumber!.isNotEmpty) {
              // Farmer
              log("Phone number: ${user.phoneNumber}");
              return const FarmerHomeScreen();
            }
          }
          // User is not signed in or does not match the criteria
          return const FarmerAuthScreen();
        },
      ),
    );
  }
}
