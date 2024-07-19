import 'package:farmnets/screens/farmer/farmer_auth_screen.dart';
import 'package:farmnets/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../auth/auth_service_farmer.dart';
import '../../chat_feature/screens/recent_chat.dart';
import '../../chat_feature/screens/start_new_chat.dart';
import '../settings_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  //int _currentTabIndex = 0;

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
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
        title: Text(AppLocalizations.of(context)!.appName,
            style: const TextStyle(
              fontSize: 20,
              color: blackColor,
              fontWeight: FontWeight.w600,
            )),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: Text(AppLocalizations.of(context)!.settings),
              ),
              /* const PopupMenuItem<String>(
                value: 'about',
                child: Text('About Us'),
              ), */
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
              } else if (value == 'logout') {
                AuthServiceFarmer.logout();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FarmerAuthScreen()));
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert, color: Colors.black, size: 28),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: tabColor,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const StartNewChat()));
        },
        child: const Icon(
          Icons.message,
          color: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RecentChat(
            currentUserIsFarmer: true,
          )
        ],
      ),
    );
  }
}
