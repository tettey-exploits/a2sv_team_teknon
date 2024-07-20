import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static const baseURL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  LocationService(this.apiKey);

  Future<String> _getCurrentCity() async {
    // get permission from user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // fetch the current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // convert the location into a list of place mark objects
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    //extract the city name from the first place mark
    String? city = placemarks[0].locality;
    return city ?? "";
  }

  fetchCity() async {
    try {
      String cityName = await _getCurrentCity();
      if (kDebugMode) {
        print(cityName);
      }
      return cityName;
    }
    // any errors
    catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
