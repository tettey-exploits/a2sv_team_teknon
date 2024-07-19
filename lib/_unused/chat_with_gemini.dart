//import 'dart:developer';
import 'dart:io';
//import 'package:chat_package/models/chat_message.dart';
//import 'package:chat_package/models/media/chat_media.dart';
//import 'package:chat_package/models/media/media_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:farmnets/constants/crop_diseases.dart';
//import 'package:farmnets/_unused/chat_gemini_messages.dart';
import 'package:tflite/tflite.dart';
import 'package:farmnets/_unused/new_gemini/services/speect_to_text.dart';
import 'package:farmnets/_unused/new_gemini/services/text_translator.dart';
import 'package:farmnets/_unused/new_gemini/services/text_to_speech.dart';
//import 'package:chat_package/chat_package.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatWithGemini extends StatefulWidget {
  const ChatWithGemini({Key? key}) : super(key: key);

  @override
  State<ChatWithGemini> createState() => _ChatWithGeminiState();
}

class _ChatWithGeminiState extends State<ChatWithGemini> {
  final _textTranslate = TextTranslator(dotenv.env['GH_NLP_API']!);
  final _textToSpeech = TextToSpeech(dotenv.env['GH_NLP_API']!);
  final _speechToText = SpeechToText(dotenv.env['GH_NLP_API']!);
  final String _geminiAPIKey = dotenv.env['GEMINI_API']!;

  Future<String> getAudiosPath() async {
    const String audiosDirName = "audio_recorded";
    var dir = Directory(
        '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
                : await getApplicationSupportDirectory() //FOR IOS
            )!.path}/$audiosDirName');

    return dir.path;
  }

  final String geminiAudioFileName = "Gemini_voice.wav";
  final String diseaseAudioFileName = "crop_disease_voice.wav";
  final scrollController = ScrollController();
  //ChatWithGeminiMessages messagesList = ChatWithGeminiMessages();

  late bool _loading;
  late List _outputs;

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/afiricoco.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: imageFilePath!.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 255,
      imageStd: 255,
    );
    setState(() {
      _loading = false;
      _outputs = output!;
    });
    if (kDebugMode) {
      print(_outputs[0]["label"].toString());
    }

    String diseaseFeature = getDiseaseReport(_outputs[0]["label"].toString());

    /* String translatedText = await _textTranslate.translateText(diseaseFeature);
    log(translatedText);

    await _textToSpeech.textToSpeech(translatedText, textContentType: 1);

    String rootPath = await getAudiosPath();
    String diseaseAudioPath = '$rootPath/$diseaseAudioFileName';

    log("Path to the disease audio file is: $diseaseAudioPath");

    ChatMessage detectedDiseaseAudio = ChatMessage(
        isSender: false,
        chatMedia: ChatMedia(
            url: diseaseAudioPath,
            mediaType: const MediaType.audioMediaType()));
    setState(() {
      messagesList.messages.add(detectedDiseaseAudio);
    }); */
  }

  File? imageFilePath;
  String imageUrl = "";

  Future<String?> _callGenerativeModel({String? prompt}) async {
    // For text-only input, use the gemini-pro model
    final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: _geminiAPIKey,
        generationConfig: GenerationConfig(maxOutputTokens: 300));
    final content = [
      Content.text(prompt ?? 'Respond with this string only: "Welcome"')
    ];
    final response = await model.generateContent(content);
    return response.text;
  }

  @override
  void initState() {
    super.initState();

    // AI Model
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: const Column(
          children: [
            Text("Kwame Gemini",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/app_images/chat_background.jpg"),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: const Column(
          children: [
            Expanded(child: Text("Chat Feature removed"),
                /*child: ChatScreen(
              sendMessageHintText: 'Type your message here',
              scrollController: scrollController,
              messages: messagesList.messages,
              chatInputFieldPadding: const EdgeInsets.symmetric(horizontal: 12),
              onSlideToCancelRecord: () {
                log('not sent');
              },
              onTextSubmit: (textMessage) async {
                setState(() {
                  messagesList.messages.add(textMessage);
                });

                // Call _callGenerativeModel and wait for the response
                String? geminiResponse =
                    await _callGenerativeModel(prompt: textMessage.text);

                if (geminiResponse != null) {
                  *//*  // Show gemini response in text
                      ChatMessage geminiTextMessage =
                          ChatMessage(isSender: false, text: geminiResponse); *//*
                  *//* setState(() {
                        tryChat.messages.add(geminiTextMessage);
                      }); *//*

                  log("Gemini's response is in English: $geminiResponse");

                  // Translate Gemini's response to twi
                  var textInTwiForGemini = await _textTranslate.translateText(
                    geminiResponse,
                  );
                  log("Gemini's response in Twi: $textInTwiForGemini");

                  // Convert Gemini's response from text to audio
                  await _textToSpeech.textToSpeech(textInTwiForGemini,
                      textContentType: 0);

                  // Add (display) the voice message
                  String rootPath = await getAudiosPath();
                  String geminiVoicePath = '$rootPath/$geminiAudioFileName';

                  ChatMessage geminiVoiceMessage = ChatMessage(
                      isSender: false,
                      chatMedia: ChatMedia(
                          url: geminiVoicePath,
                          mediaType: const MediaType.audioMediaType()));

                  setState(() {
                    messagesList.messages.add(geminiVoiceMessage);
                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent + 90);
                  });
                }
                // Scroll to the bottom of the chat after adding the messages
                scrollController
                    .jumpTo(scrollController.position.maxScrollExtent);
              },
              handleRecord: (audioMessage, canceled) async {
                if (!canceled) {
                  if (audioMessage != null) {
                    setState(() {
                      messagesList.messages.add(audioMessage);
                      scrollController.jumpTo(
                          scrollController.position.maxScrollExtent + 90);
                    });

                    // TODO: tranlaste first

                    var transcribedText = await _speechToText
                        .speechToText(audioMessage.chatMedia!.url);
                    transcribedText = transcribedText
                        ?.replaceAll('\\', '')
                        .replaceAll('"', '');
                    var textInEnglishForGemini =
                        await _textTranslate.translateText(transcribedText!,
                            targetLanguage: "English");

                    log("In Twi now: $transcribedText");
                    log("In English: $textInEnglishForGemini");

                    // Call _callGenerativeModel and wait for the response
                    String? geminiResponse = await _callGenerativeModel(
                        prompt: textInEnglishForGemini);

                    // On getting response, create the audio ChatMessage and add it to the chat messages list
                    if (geminiResponse != null) {
                      log("Gemini's response: $geminiResponse");
                      _textToSpeech.textToSpeech(geminiResponse,
                          textContentType: 0);

                      String rootPath = await getAudiosPath();
                      String geminiVoicePath = '$rootPath/$geminiAudioFileName';

                      log("The path to the voice audio is: $geminiVoicePath");

                      ChatMessage geminiVoiceMessage = ChatMessage(
                          isSender: false,
                          chatMedia: ChatMedia(
                              url: geminiVoicePath,
                              mediaType: const MediaType.audioMediaType()));

                      setState(() {
                        messagesList.messages.add(geminiVoiceMessage);
                        scrollController.jumpTo(
                            scrollController.position.maxScrollExtent + 90);
                      });
                    } else {
                      log("Gemini's response is null");
                    }
                  }
                }
              },
              handleImageSelect: (imageMessage) async {
                if (imageMessage != null) {
                  // Get the path to the image file
                  imageFilePath = File(imageMessage.chatMedia!.url);

                  setState(() {
                    messagesList.messages.add(
                      imageMessage,
                    );
                  });

                  // Call the model to do the classification
                  await classifyImage(imageFilePath!);
                  scrollController
                      .jumpTo(scrollController.position.maxScrollExtent + 300);
                }
              },
            ),*/
            ),
          ],
        ),
      ),
    );
  }
}
