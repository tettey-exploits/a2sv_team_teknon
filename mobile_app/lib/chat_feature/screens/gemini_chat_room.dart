import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmnets/auth/auth_service_officer.dart';
import 'package:farmnets/chat_feature/components/audio_controller.dart';
import 'package:farmnets/chat_feature/widgets/chat_bubble.dart';
import 'package:farmnets/chat_feature/widgets/chat_text_field.dart';
import 'package:farmnets/chat_feature/services/gemini_service.dart';

//import 'package:farmnets/themes/light_mode.dart';
import 'package:farmnets/constants/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmnets/providers/locale_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

//import 'package:tflite/tflite.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:farmnets/services/ghana_nlp_services.dart';
import 'package:farmnets/services/disease_detection.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiChatRoom extends StatefulWidget {
  const GeminiChatRoom({
    super.key,
  });

  @override
  State<GeminiChatRoom> createState() => _GeminiChatRoomState();
}

class _GeminiChatRoomState extends State<GeminiChatRoom> {
  String receiverName = "Kwame Gemini";
  String receiverID = "gemini";

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  final TextEditingController _messageController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final AuthServiceOfficer _authService = AuthServiceOfficer();
  final ScrollController _scrollController = ScrollController();
  bool isTextMode = false;
  String? selectedImagePath;
  final audioController = AudioController();
  String? currentLanguage;
  final GhanaNLPServices _nlpServices =
      GhanaNLPServices(apiKey: dotenv.env['GH_NLP_API']!);
  final DiseaseDetection _diseaseDetection = DiseaseDetection();

  void sendTextMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _geminiService.userSendMessage(
          textMessage: _messageController.text);

      if (mounted) {
        // clear text controller
        _messageController.clear();

        scrollDown();
      }
    }
  }

  void sendGeminiReply() async {
    if (_messageController.text.isNotEmpty) {
      if (currentLanguage != null) {
        await _geminiService.callGenerativeModel(
            textPrompt: _messageController.text,
            userLanguage: currentLanguage!);
      } else {
        // Just to handle errors
        await _geminiService.callGenerativeModel(
            textPrompt: _messageController.text);
      }

      if (mounted) {
        // clear text controller
        _messageController.clear();

        scrollDown();
      }
    }
  }

  void sendImageMessage({required File imageFile}) async {
    await _geminiService.userSendMessage(
      imageFile: imageFile,
    );

    String? report =
        await _diseaseDetection.detectCropDisease(cropImage: imageFile);

    // If report is not null,
    if (report != null) {
      //TODO: use correct implementation below
      if (currentLanguage != null && currentLanguage != "en") {
        // translate from English to local language
        String? translatedText = await _nlpServices.translateText(report,
            localLanguage: currentLanguage!);
        log("Translated text: $translatedText\n");
        if (translatedText == "401") {
          log("Check API key");
          return;
        }
        // conversion from text to speech
        int statusCode = await _nlpServices.textToSpeech(
            text: translatedText,
            textSource: 1,
            targetLanguage: currentLanguage!);

        // handle failure
        // Other case already handled in GhanaNLPServices class
        if (statusCode == 500) {
          // Send text message in local language to Firestore
          await _geminiService.geminiMessageToFirestore(
              textMessage: translatedText);
        }
      } else if (currentLanguage == "en") {
        // Send text message in English to Firestore
        await _geminiService.geminiMessageToFirestore(textMessage: report);
      }
      // Check mode
      // If text mode, check language and send text message as reply
      // If audio mode, check language and send audio as reply
    }

    if (mounted) {
      // clear text controller
      _messageController.clear();
      scrollDown();
    }
  }

  void sendAudioMessage({required File audioFile}) async {
    await _geminiService.userSendMessage(
      audioFile: audioFile,
    );
    if (currentLanguage != null && currentLanguage != "en") {
      // Speech-to-text
      String? transcription = await _nlpServices.speechToText(audioFile.path);
      if (transcription != null) {
        // Translate from local language to English
        log("Transcription: $transcription\n");
        String? translatedText = await _nlpServices.translateText(transcription,
            currentLanguage: currentLanguage!);
        log("Translated text: $translatedText\n");
        if (translatedText == "401") {
          log("Check API key");
          return;
        }
        await _geminiService.callGenerativeModel(textPrompt: translatedText);
      } else {
        log("Transcription failed");
      }
    }

    if (mounted) {
      // clear text controller
      _messageController.clear();

      scrollDown();
    }
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _diseaseDetection.loadModel();
    // Add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // Cause a delay so that keyboard has time to show up, then
        // calc. the amount of space remaining, then
        // scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollDown();
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    currentLanguage = localeProvider.locale.toString();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            receiverName,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        body: Stack(children: [
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Image.asset("assets/app_images/chat_background_light.jpeg",
                  fit: BoxFit.cover)),
          Column(children: [
            // display all messages
            Expanded(
              child: _buildMessageList(),
            ),

            // user input
            _buildUserInput(),
          ]),
        ]));
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: _geminiService.getMessages(senderID),
        builder: (context, snapshot) {
          // Errors
          if (snapshot.hasError) {
            return const Text("Error");
          }

          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            /*return const Text("Loading...");*/
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// This was a bug fix. No longer needed?
          /*if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No messages"),
            );
          }*/

          // Return List View
          return ListView(
            controller: _scrollController,
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // parse timestamp
    DateTime timeStamp = (data['timestamp'] as Timestamp).toDate();

    bool isFromGemini = data["isGeminiReply"] ?? false;

    // align to the right if sender is the current user, otherwise, left,
    var alignment = isFromGemini ? Alignment.centerLeft : Alignment.centerRight;

    return Container(
      alignment: alignment,
      child: ChatBubble(
        message: data["message"],
        imageUrl: data["imageUrl"],
        audioUrl: data["audioUrl"],
        timeStamp: timeStamp,
        isCurrentUser: isFromGemini,
        // Texts from Gemini are mostly translated
        isTranslatedText: isFromGemini,
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppPadding.p5(context),
        //bottom: 5.0,
      ),
      child: Stack(children: [
        Visibility(
          visible: isTextMode,
          child: Row(
            children: [
              GestureDetector(
                child: const Icon(Icons.close),
                onTap: () {
                  setState(() {
                    isTextMode = !isTextMode;
                  });
                },
              ),
              Expanded(
                  child: ChatTextField(
                controller: _messageController,
                hintText: "Type a message",
                //obscureText: false,
                focusNode: myFocusNode,
              )),
              Container(
                decoration: const BoxDecoration(
                    color: Color(0xff25D366), shape: BoxShape.circle),
                margin: const EdgeInsets.only(right: 6.0, left: 6.0),
                child: IconButton(
                  onPressed: () {
                    sendTextMessage();
                    sendGeminiReply();
                  },
                  icon: const Icon(Icons.send_rounded),
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: !isTextMode,
          child: Stack(
            children: [
              Positioned(
                top: 15,
                child: Container(
                  height: 45,
                  width: 170,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    //color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    //height: 45,
                    height: ScreenSize.adjustedHeight(context, 5),
                    //width: 50,
                    width: ScreenSize.adjustedWidth(context, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        topLeft: Radius.circular(15),
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          isTextMode = !isTextMode;
                        });
                      },
                      icon: const Icon(Icons.keyboard, size: 32),
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    //height: 75,
                    height: ScreenSize.adjustedHeight(context, 8.5),
                    //width: 75,
                    width: ScreenSize.adjustedWidth(context, 18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                        bottom: Radius.circular(24),
                      ),
                    ),
                    child: GestureDetector(
                        onLongPress: () async {
                          var audioPlayer = AudioPlayer();
                          await audioPlayer.play(
                              AssetSource("app_audio/record_audio_sound.mp3"));
                          audioPlayer.onPlayerComplete.listen((a) {
                            audioController.start.value = DateTime.now();
                            startRecord();
                            audioController.isRecording.value = true;
                          });
                        },
                        onLongPressEnd: (details) {
                          stopRecord();
                        },
                        child: const Icon(
                          Icons.mic,
                          size: 32,
                          color: Colors.white,
                        )),
                    //color: Colors.white,
                  ),
                  Container(
                    //height: 45,
                    height: ScreenSize.adjustedHeight(context, 5),
                    //width: 50,
                    width: ScreenSize.adjustedWidth(context, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showImagePickerOption(context);
                      },
                      icon: const Icon(Icons.camera_alt, size: 32),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }

  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImagePath = returnImage.path;
    });
    log("Image path $selectedImagePath");
    return returnImage.path;
    /*if (mounted) {
      Navigator.of(context).pop(); //close the model sheet
    }*/
  }

  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImagePath = returnImage.path;
    });
    log("Image path $selectedImagePath");
    return returnImage.path;
    /*if (mounted) {
      Navigator.of(context).pop();
    }*/
  }

  void showImagePickerOption(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Add image from:'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height / 7,
                child: Column(
                  children: [
                    ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text('Gallery'),
                        onTap: () async {
                          Navigator.of(context).pop();
                          final selectedPath = await _pickImageFromGallery();
                          if (selectedPath != null) {
                            setState(() {
                              selectedImagePath = selectedPath;
                            });
                            log("Selected Image Path from gallery: $selectedImagePath");
                            sendImageMessage(
                                imageFile: File(selectedImagePath!));
                          }
                        }),
                    ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Take Photo'),
                        onTap: () async {
                          Navigator.of(context).pop();
                          final selectedPath = await _pickImageFromCamera();
                          if (selectedPath != null) {
                            setState(() {
                              selectedImagePath = selectedPath;
                            });
                            log("Selected Image Path from camera: $selectedImagePath");
                            sendImageMessage(
                                imageFile: File(selectedImagePath!));
                          }
                        })
                  ],
                ),
              ));
        });
  }

  late String recordFilePath;
  int i = 0;

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath =
        "${storageDirectory.path}/record${DateTime.now().microsecondsSinceEpoch}.acc";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/test_${i++}.mp3";
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();
      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
    } else {}
    setState(() {});
  }

  void stopRecord() async {
    bool stop = RecordMp3.instance.stop();
    audioController.end.value = DateTime.now();
    audioController.calcDuration();
    var ap = AudioPlayer();
    await ap.play(AssetSource("app_audio/record_audio_sound.mp3"));
    ap.onPlayerComplete.listen((a) {});
    if (stop) {
      audioController.isRecording.value = false;
      audioController.isSending.value = true;
      log("Recorded audio path: $recordFilePath");

      // Create a File instance with the recorded file path
      File recordedFile = File(recordFilePath);

      // Send the audio message
      sendAudioMessage(audioFile: recordedFile);
    }
  }
}
