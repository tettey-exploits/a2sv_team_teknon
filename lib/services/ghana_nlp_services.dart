import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../chat_feature/services/gemini_service.dart';

class GhanaNLPServices {
  final String apiKey;

  GhanaNLPServices({required this.apiKey});

  Future<String> translateText(String text,
      {String? currentLanguage, String? localLanguage}) async {
    const baseURL = 'https://translation-api.ghananlp.org/v1/translate';
    late http.Response response;

    // If localLanguage != null, translate from English to local language
    if (localLanguage != null) {
      response = await http.post(Uri.parse(baseURL),
          headers: {
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Ocp-Apim-Subscription-Key": apiKey
          },
          body: jsonEncode({"in": text, "lang": "en-$localLanguage"}));
    } else if (currentLanguage != null) {
      // If localLanguage == null, translate from local language to English
      response = await http.post(Uri.parse(baseURL),
          headers: {
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Ocp-Apim-Subscription-Key": apiKey
          },
          // TRANSLATION TO ENGLISH
          body: jsonEncode({"in": text, "lang": "$currentLanguage-en"}));
    }

    if (response.statusCode == 200) {
      // Ensure the response body is decoded as UTF-8
      String result = utf8.decode(response.bodyBytes);

      // Remove the first and last quotation marks if they exist
      if (result.startsWith('"') && result.endsWith('"')) {
        result = result.substring(1, result.length - 1);
      }

      return result;
    } else {
      return response.statusCode.toString();
    }
  }

  Future<String?> speechToText(String recordedAudioPath) async {
    const baseURL =
        'https://translation-api.ghananlp.org/asr/v1/transcribe?language=tw&wav=False';

    File audioFile = File(recordedAudioPath);
    if (!await audioFile.exists()) {
      throw Exception("Audio file not found.\n");
    }
    try {
      final bytes = await audioFile.readAsBytes();

      final response = await http.post(Uri.parse(baseURL),
          headers: {
            "Content-Type": "audio/m4a",
            "Cache-Control": "no-cache",
            "Ocp-Apim-Subscription-Key": apiKey
          },
          body: bytes);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(jsonEncode(response.body));
        }
        // Ensure the response body is decoded as UTF-8
        String result = utf8.decode(response.bodyBytes);

        // Remove the first and last quotation marks if they exist
        if (result.startsWith('"') && result.endsWith('"')) {
          result = result.substring(1, result.length - 1);
        }

        return result;
      } else {
        throw Exception("Failed to fetch text data: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  Future<int> textToSpeech({
    required String text,
    required String targetLanguage,
    required int textSource,
  }) async {
    const baseURL = 'https://translation-api.ghananlp.org/tts/v1/tts';

    try {
      final response = await http.post(
        Uri.parse(baseURL),
        headers: {
          "Content-Type": "application/json",
          "Cache-Control": "no-cache",
          "Ocp-Apim-Subscription-Key": apiKey,
        },
        body: jsonEncode({"text": text, "language": targetLanguage}),
      );

      if (response.statusCode == 200) {
        List<int> audioData = response.bodyBytes;

        /*
        // SAVE TO LOCAL STORAGE
        final directoryPath =
            await createFolderForAudio(dirName: 'translated_audio');
        if (directoryPath == null) {
          throw Exception('Failed to create or access directory');
        }

        late final String fileName;
        if (textSource == 0) {
          fileName = "gemini_response.wav";
        } else if (textSource == 1) {
          fileName = "crop_disease_report.wav";
        } else {
          throw Exception('Invalid textSource value');
        }

        final filePath = '$directoryPath/$fileName';

        // Write audio data to the file
        final file = File(filePath);
        await file.writeAsBytes(audioData);
        */

        // UPLOAD audioBytes TO FIRESTORE
        final geminiService = GeminiService();
        await geminiService.geminiMessageToFirestore(
          textMessage: "",
          audioBytes: audioData,
          fromNLPService: true,
        );

        return 200;
      } else {
        log("Failed to fetch audio data: ${response.statusCode} - ${response.reasonPhrase}");
        return response.statusCode;
      }
    } catch (e) {
      log("Error in textToSpeech: $e");
      return -1; // Indicate an error occurred
    }
  }

  Future<String> createFolderForAudio({required String dirName}) async {
    late Directory directory;

    if (Platform.isAndroid) {
      directory =
          Directory('${(await getExternalStorageDirectory())!.path}/$dirName');
    } else if (Platform.isIOS) {
      directory = Directory(
          '${(await getApplicationSupportDirectory()).path}/$dirName');
    } else {
      await openAppSettings();
      throw UnsupportedError('Unsupported platform');
    }

    /* final dir = Directory(
        '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
                : await getApplicationSupportDirectory() //FOR IOS
            )!.path}/$dirName'); */

    final PermissionStatus result = await (Platform.isAndroid
        ? (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 33
            ? Permission.audio.request()
            : Permission.storage.request()
        : Permission.audio.request());

    /* var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } */
    if (result.isGranted) {
      if ((await directory.exists())) {
        return directory.path;
      } else {
        directory.create();
        return directory.path;
      }
    }

    throw Exception('Could not obtain directory path');
  }
}
