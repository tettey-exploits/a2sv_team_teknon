import 'package:farmnets/chat_feature/screens/users_chat_room.dart';
//import 'package:farmnets/components/widgets/profile_widget.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_service_officer.dart';
import '../widgets/user_tile.dart';
import '../services/chat_service.dart';

class StartNewChat extends StatefulWidget {
  const StartNewChat({super.key});

  @override
  State<StartNewChat> createState() => _StartNewChatState();
}

class _StartNewChatState extends State<StartNewChat> {
  final ChatService _chatService = ChatService();
  final AuthServiceOfficer _authService = AuthServiceOfficer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Extension Officers"),
        ),
        body: _buildUserList()
        );
  }

  Widget _buildUserList() {
    // if user is farmer, get only the extension officer
    // otherwise, display farmers
    return StreamBuilder(
      stream: _chatService.getExtensionOfficersStream(),
      //stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // Return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
          text: userData["username"],
          showLastMessage: false,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UsersChatRoom(
                          receiverName: userData["username"],
                          receiverID: userData["uid"],
                        )));
          });
    } else {
      return Container();
    }
  }
}
