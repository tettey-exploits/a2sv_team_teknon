/* import 'dart:developer';

import 'package:chat_package/chat_package.dart';
import 'package:chat_package/models/chat_message.dart';
import 'package:chat_package/models/media/chat_media.dart';
import 'package:chat_package/models/media/media_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmnets/themes/light_mode.dart';
import 'package:farmnets/chat_feature/components/user_gemini_messages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

class FarmerOfficerChat extends StatefulWidget {
  const FarmerOfficerChat({super.key});

  @override
  State<FarmerOfficerChat> createState() => _FarmerOfficerChatState();
}

class _FarmerOfficerChatState extends State<FarmerOfficerChat> {
  final TextEditingController _textMessageController = TextEditingController();
  bool _isDisplaySendButton = false;
  bool _isDisplayTextField = false;

  final ScrollController scrollController = ScrollController();
  final UserGeminiMessages userMessages = UserGeminiMessages();

  @override
  void dispose() {
    _textMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text("Username"),
            Text("Online",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))
          ],
        ),
        /* actions: const [
            Icon(Icons.more_vert, size: 27),
          ], */
      ),
      body: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Image.asset("assets/app_images/chat_background.jpg",
                  fit: BoxFit.cover)),
          Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _messageLayout(
                      message: "Hello",
                      alignment: Alignment.centerRight,
                      createAt: Timestamp.now(),
                      isSeen: false,
                      isShowTick: true,
                      messageBgColor: messageColor,
                      onLongPress: () {},
                      onSwipe: (dragUpdateDetails) {},
                    ),
                    _messageLayout(
                      message: "How are you?",
                      alignment: Alignment.centerRight,
                      createAt: Timestamp.now(),
                      isSeen: false,
                      isShowTick: true,
                      messageBgColor: messageColor,
                      onLongPress: () {},
                      onSwipe: (dragUpdateDetails) {},
                    ),
                    _messageLayout(
                      message: "Hi",
                      alignment: Alignment.centerLeft,
                      createAt: Timestamp.now(),
                      isSeen: false,
                      isShowTick: false,
                      messageBgColor: senderMessageColor,
                      onLongPress: () {},
                      onSwipe: (dragUpdateDetails) {},
                    ),
                    _messageLayout(
                      message: "Great. You?",
                      alignment: Alignment.centerLeft,
                      createAt: Timestamp.now(),
                      isSeen: false,
                      isShowTick: false,
                      messageBgColor: senderMessageColor,
                      onLongPress: () {},
                      onSwipe: (dragUpdateDetails) {},
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
                child: _isDisplayTextField
                    ? Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                //color: appBarColor,
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height: 50,
                              child: TextField(
                                controller: _textMessageController,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      _isDisplaySendButton = true;
                                    });
                                  } else {
                                    setState(() {
                                      _isDisplaySendButton = false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    hintText: "Type a message",
                                    border: InputBorder.none,
                                    suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: Wrap(children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isDisplayTextField = false;
                                              });
                                            },
                                            child: const Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.black,
                                            ),
                                          )
                                        ]))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: _isDisplaySendButton
                                      ? tabColor
                                      : Colors.grey),
                              child: const Center(
                                  child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                              )))
                        ],
                      )
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            //color: appBarColor,
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: 50,
                          width: 150,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isDisplayTextField = true;
                                      });
                                    },
                                    child:
                                        const Icon(Icons.keyboard, size: 35)),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Icon(Icons.mic, size: 35),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child:
                                      const Icon(Icons.photo_camera, size: 35),
                                ),
                              ]),
                        ),
                      ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _messageLayout({
    Color? messageBgColor,
    Alignment? alignment,
    Timestamp? createAt,
    //VoidCallback? onSwipe,
    void Function(DragUpdateDetails)? onSwipe,
    //double? rightPadding,
    String? message,
    bool? isShowTick,
    bool? isSeen,
    VoidCallback? onLongPress,
  }) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: SwipeTo(
          onRightSwipe: onSwipe,
          child: GestureDetector(
            onLongPress: onLongPress,
            child: Container(
              alignment: alignment,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.only(
                            left: 5,
                            right: 85,
                            top: 5,
                            bottom: 5,
                          ),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.80),
                          decoration: BoxDecoration(
                              color: messageBgColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text("$message",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12))),
                      const SizedBox(height: 3),
                    ],
                  ),
                  Positioned(
                    bottom: 4,
                    right: 10,
                    child: Row(
                      children: [
                        Text(DateFormat.jm().format(createAt!.toDate()),
                            style: const TextStyle(
                                fontSize: 12, color: greyColor)),
                        const SizedBox(width: 5),
                        isShowTick == true
                            ? Icon(
                                isSeen == true ? Icons.done_all : Icons.done,
                                size: 16,
                                color: isSeen == true ? Colors.blue : greyColor,
                              )
                            : Container(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
 */