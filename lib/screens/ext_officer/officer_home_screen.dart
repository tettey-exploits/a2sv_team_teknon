import 'dart:developer';

import 'package:farmnets/screens/farmer/farmer_auth_screen.dart';
import 'package:provider/provider.dart';
import 'officer_profile_screen.dart';
import '../../chat_feature/screens/recent_chat.dart';
import '../settings_screen.dart';
import 'package:farmnets/auth/auth_service_officer.dart';
//import 'package:farmnets/screens/farmer/farmer_authentication.dart';
import 'package:farmnets/themes/light_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:farmnets/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../database/ext_officer_db.dart';

class OfficerHomeScreen extends StatefulWidget {
  //final String username;
  const OfficerHomeScreen({
    super.key,
    /* required this.username */
  });

  @override
  State<OfficerHomeScreen> createState() => _OfficerHomeScreenState();
}

class _OfficerHomeScreenState extends State<OfficerHomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  //int _currentTabIndex = 0;
  final localDb = ExtensionOfficerDB();
  String? name;
  String? email;
  String? imagePath;

  //String get username => widget.username;

  logout(BuildContext context) {
    final auth = AuthServiceOfficer();
    auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const FarmerAuthScreen()),
    );
  }

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    email = userProvider.email;
    log("Officer email: $email");
    getOfficerDetails(officerEmail: email);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appName,
          style: const TextStyle(
              fontSize: 20, color: textColor, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              PopupMenuItem<String>(
                value: 'about',
                child: Text(AppLocalizations.of(context)!.aboutUs),
              ),
              PopupMenuItem<String>(
                value: 'profile',
                child: Text(AppLocalizations.of(context)!.profile),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text(AppLocalizations.of(context)!.logout),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SettingsScreen()), // Navigate to settings page
                );
              } else if (value == 'about') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(AppLocalizations.of(context)!.aboutUs),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.appName,
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .theFarmersVoiceBasedPersonalAssistant,
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                      ],
                    );
                  },
                );
              } else if (value == 'logout') {
                logout(context);
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OfficerProfileScreen(
                          officerName: name ?? " ",
                          email: email ?? " ",
                          imagePath:
                              imagePath ?? "")), // Navigate to profile page
                );
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert, color: Colors.white, size: 28),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: tabColor,
          unselectedLabelColor: greyColor,
          indicatorColor: tabColor,
          tabs: [
            Tab(
                child: Text(
              AppLocalizations.of(context)!.chats,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RecentChat(
            currentUserIsFarmer: false,
          )
        ],
      ),
    );
  }

  Future<void> getOfficerDetails({required String? officerEmail}) async {
    if (officerEmail != null) {
      log("Getting details of $officerEmail");
      try {
        final details = await localDb.fetchByEmail(officerEmail);
        setState(() {
          name = details.name;
          email = details.email;
          imagePath = details.imagePath;
        });
        log("Done getting details.");
      } catch (e) {
        log("Error getting details: $e");
      }
    } else {
      log("Incorrect officer email provided");
    }
  }
}
