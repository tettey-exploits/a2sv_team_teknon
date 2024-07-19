import 'dart:developer';
import 'package:geocoding/geocoding.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ClimatePattern {
  static const BASE_URL =
      'https://history.openweathermap.org/data/2.5/history/city';
  final String apiKey;

  ClimatePattern({required this.apiKey});

  Future<Map<String, double>> _getCoordinates(String cityName) async {
    try {
      // Use the geocoding API to get the coordinates of the city
      List<Location> locations = await locationFromAddress(cityName);

      if (locations.isNotEmpty) {
        // Extract latitude and longitude from the first result
        double latitude = locations[0].latitude;
        double longitude = locations[0].longitude;

        return {'latitude': latitude, 'longitude': longitude};
      } else {
        throw Exception('No coordinates found for the city: $cityName');
      }
    } catch (e) {
      // Handle any errors that occur during the geocoding process
      log('Error getting coordinates: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getCityClimatePattern(String cityName) async {
    Map<String, double> coordinates = await _getCoordinates(cityName);

    double latitude = coordinates['latitude']!;
    double longitude = coordinates['longitude']!;

    log('The API key is: $apiKey');

    log('Latitude is $latitude\n Longitude is $longitude');

    String url = '$BASE_URL?lat=$latitude&lon=$longitude&appid=$apiKey';

    // Make a GET request to fetch the historical weather data
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception(
          'Failed to fetch historical weather data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchCityClimatePattern(String cityName) async {
    try {
      // Fetch historical weather data for the specified city
      Map<String, dynamic> climatePatternData =
          await _getCityClimatePattern(cityName);
      return climatePatternData;
    } catch (e) {
      // Handle any errors that occur during the fetch operation
      log('Error fetching climate pattern: $e');
      rethrow; // Optionally rethrow the error to propagate it to the caller
    }
  }
}
