import 'dart:developer';
import 'package:farmnets/auth/auth_service_officer.dart';
import 'package:farmnets/chat_feature/widgets/user_tile.dart';
import 'package:farmnets/chat_feature/screens/users_chat_room.dart';
import 'package:farmnets/chat_feature/services/chat_service.dart';
import 'package:farmnets/chat_feature/services/gemini_service.dart';
import 'package:farmnets/widgets/profile_widget.dart';
import 'package:farmnets/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'gemini_chat_room.dart';

class RecentChat extends StatelessWidget {
  final bool currentUserIsFarmer;

  RecentChat({super.key, required this.currentUserIsFarmer});

  final ChatService _chatService = ChatService();
  final GeminiService _geminiService = GeminiService();
  final AuthServiceOfficer _authService = AuthServiceOfficer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Stack(children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GeminiChatRoom()));
            },
            child: StreamBuilder<String>(
                stream: _geminiService.getLastMessage(
                  userID: _authService.getCurrentUser()!.uid,
                  otherUserID: "gemini",
                ),
                builder: (context, snapshot) {
                  String lastMessage = "Akwaaba!";
                  if (snapshot.hasData) {
                    lastMessage = snapshot.data!;
                  }
                  return ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: kwameGeminiProfileWidget(),
                      ),
                    ),
                    title: Text(AppLocalizations.of(context)!.kwameGemini,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      children: [
                        Text(
                          DateFormat.jm().format(DateTime.now()),
                          style:
                              const TextStyle(color: greyColor, fontSize: 12),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10),
                          child: Icon(Icons.push_pin, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ]),
        Expanded(
          child: _buildUserList(),
        ),
      ]),
    );
  }

  Widget _buildUserList() {
    // if user is farmer, get only the extension officer
    // otherwise, display farmers
    return StreamBuilder(
      stream: currentUserIsFarmer == true
          ? _chatService.getExtensionOfficersStream()
          : _chatService.getFarmersStream(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        if (snapshot.hasData) {
          final userList = snapshot.data!;
          return ListView(
            children: userList
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList(),
          );
        } else {
          return const Text("No data available");
        }
      },
    );
  }

  // build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    final username = userData["username"] as String?;
    final uid = userData["uid"] as String?;
    final email = userData["email"] as String?;

    if (username == null || uid == null || email == null) {
      log("User data is incomplete: $userData");
      return Container();
    }

    return StreamBuilder<String>(
      stream: _chatService.getLastMessage(
        userID: _authService.getCurrentUser()!.uid,
        otherUserID: uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(); // or a loading placeholder
        } else if (snapshot.hasError) {
          log("Error fetching last message: ${snapshot.error}");
          return Container(); // or an error placeholder
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return UserTile(
            text: username,
            showLastMessage: true,
            userID: _authService.getCurrentUser()!.uid,
            otherUserID: uid,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersChatRoom(
                    receiverName: username,
                    receiverID: uid,
                  ),
                ),
              );
            },
          );
        } else {
          return Container(); // No chat history, do not display the tile
        }
      },
    );
  }
}
