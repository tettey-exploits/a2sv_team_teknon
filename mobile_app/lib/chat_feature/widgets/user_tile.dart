import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../widgets/profile_widget.dart';
import '../../themes/light_mode.dart';
import 'package:farmnets/chat_feature/services/chat_service.dart';

class UserTile extends StatefulWidget {
  final String text;
  final void Function()? onTap;
  final String? profileImageUrl;
  final String? lastMessage;
  final bool? showLastMessage;
  final String? otherUserID;
  final String? userID;

  const UserTile({
    super.key,
    required this.text,
    this.onTap,
    this.profileImageUrl,
    this.lastMessage,
    this.showLastMessage,
    this.otherUserID,
    this.userID,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
            margin: const EdgeInsets.symmetric(vertical: 0.3),
            padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15),
            color: Colors.white,
            child: Row(children: [
              SizedBox(
                  width: 50,
                  height: 50,
                  child: profileWidget(imageUrl: widget.profileImageUrl)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.showLastMessage == true &&
                        widget.userID != null &&
                        widget.otherUserID != null)
                      StreamBuilder<String>(
                        stream: _chatService.getLastMessage(
                          userID: widget.userID!,
                          otherUserID: widget.otherUserID!,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Loading...");
                          } else if (snapshot.hasError) {
                            return const Text(
                                "Error"); // Placeholder for error state
                          } else if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          } else {
                            return const Text("");
                          }
                        },
                      )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.jm().format(DateTime.now()),
                      style: const TextStyle(color: greyColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
