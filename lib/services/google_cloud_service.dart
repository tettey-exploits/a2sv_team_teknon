import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleCloudService {
  final String accessToken;
  String endpointId = dotenv.env['GoogleCloudEndpointID']!;
  String projectId = dotenv.env['GoogleCloudProjectID']!;

  GoogleCloudService({
    required this.accessToken,
  });

  Future<void> executeRequest({required Map<String, dynamic> inputData}) async {
    String inputDataFile = jsonEncode(inputData);
    final url = Uri.parse(
        "https://us-central1-aiplatform.googleapis.com/v1/projects/$projectId/locations/us-central1/endpoints/$endpointId:predict");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json"
      },
      body: inputDataFile,
    );

    if (response.statusCode == 200) {
      // Request successful, handle response here
      log("Response: ${response.body}");
    } else {
      // Request failed, handle error here
      log("Error: ${response.statusCode}");
      log("Body: ${response.body}");
    }
  }
}
