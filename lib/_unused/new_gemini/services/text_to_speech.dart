import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class TextToSpeech {
  static const BASE_URL = 'https://translation-api.ghananlp.org/tts/v1/tts';
  final String apiKey;

  TextToSpeech(this.apiKey);

  Future<void> textToSpeech(String text,
      {String? targetLanguage, required int textContentType}) async {
    final response = await http.post(Uri.parse(BASE_URL),
        headers: {
          "Content-Type": "application/json",
          "Cache-Control": "no-cache",
          "Ocp-Apim-Subscription-Key": apiKey
        },
        body: jsonEncode({"text": text, "language": "tw"}));

    if (response.statusCode == 200) {
      List<int> audioData = response.bodyBytes;

      /// Create dir isNotExist and save the audio to the file
      final directoryPath = await createFolderForAudio(dirName: "audio_recorded");

      late final String fileName;
     if (textContentType == 0) {
        fileName = "Gemini_voice.wav";
      } else if (textContentType == 1) {
        fileName = "crop_disease_voice.wav";
      }

      final filePath = '$directoryPath/$fileName';

      /// Write audio data to the file
      await File(filePath).writeAsBytes(audioData);
    } else {
      throw Exception("Failed to fetch audio data: ${response.statusCode}");
    }
  }

  /* Future<String> createFolder(String dirName) async {
    /* final dir = Directory(
        '/storage/emulated/0/Android/data/com.FarmNETS.farmnets/files/$dirName'); */
    final dir = Directory(
        '${(Platform.isAndroid ? await getExternalStorageDirectory() //FOR ANDROID
                : await getApplicationSupportDirectory() //FOR IOS
            )!.path}/$dirName');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await dir.exists())) {
      return dir.path;
    } else {
      dir.create();
      return dir.path;
    }
  } */

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

    final PermissionStatus result = await (Platform.isAndroid
        ? (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 33
            ? Permission.audio.request()
            : Permission.storage.request()
        : Permission.audio.request());

    if (result.isGranted) {
      if ((await directory.exists())) {
        return directory.path;
      } else {
        await directory.create();
        return directory.path;
      }
    }

    throw Exception('Could not obtain directory path');
  }

  /* Future<String> getCurrentCity() async {
    // get permission from user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // fetch the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // convert the location into a list of placemark objects
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    //extract the city name from the first placemark
    String? city = placemarks[0].locality;
    return city ?? "";
  } */
}
