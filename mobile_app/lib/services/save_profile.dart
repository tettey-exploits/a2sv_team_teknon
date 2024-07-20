import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

class SaveProfile {
  Future<String> uploadImageToFirebase(String childName, Uint8List file) async {
    Reference ref = _firebaseStorage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /*Future<String> saveToFirestoreOfficer({
    required String name,
    required String contact,
    required String location,
    required int rating,
    required Uint8List imageFile,
  }) async {
    String resp = "Some Error Occurred.";
    try {
      if (name.isNotEmpty || contact.isNotEmpty) {
        String imageUrl =
            await uploadImageToFirebase('profileImage_$contact', imageFile);
        await _fireStore.collection('OfficerProfile').add({
          'name': name,
          'contact': contact,
          'location': location,
          'rating': rating,
          'imageLink': imageUrl,
        });
        resp = "Success";
      }
    } catch (error) {
      resp = error.toString();
    }

    return resp;
  }*/

  /*Future<String> saveToFirestoreFarmer({
    required String name,
    required String contact,
    required String location,
    required int rating,
  }) async {
    String resp = "Some Error Occurred.";
    try {
      if (name.isNotEmpty || contact.isNotEmpty) {
        await _fireStore.collection('FarmerProfile').add({
          'name': name,
          'contact': contact,
          'location': location,
          'rating': rating,
        });
        resp = "Success";
      }
    } catch (error) {
      resp = error.toString();
    }

    return resp;
  }*/

  Future<String> saveToFirestoreGeminiFarmer({
    required String name,
    required String contact,
    required String location,
    required int rating,
  }) async {
    String resp = "An Error Occurred.";
    try {
      if (name.isNotEmpty || contact.isNotEmpty) {
        await _fireStore.collection('GeminiFarmerProfile').add({
          'name': name,
          'contact': contact,
          'location': location,
          'rating': rating,
        });
        resp = "Success";
      }
    } catch (error) {
      resp = error.toString();
    }

    return resp;
  }

  /*Future<String> fireStoreCreateRegionalSoilXtics() async {
    final List<Map<String, dynamic>> soilData = [
      {
        'region': 'Ashanti',
        'pH': {'min': 4.1, 'max': 7.3},
        'organicMatter': {'min': 0, 'max': 13.83},
        'totalNitrogen': {'min': 0, 'max': 0.52},
        'availablePhosphorus': {'min': 0, 'max': 6.89},
        'cationExchangeCapacity': {'min': 0, 'max': 0.92}
      },
      {
        'region': 'Brong Ahafo',
        'pH': {'min': 4.1, 'max': 7.7},
        'organicMatter': {'min': 0, 'max': 13.83},
        'totalNitrogen': {'min': 0, 'max': 0.52},
        'availablePhosphorus': {'min': 0, 'max': 0.41},
        'cationExchangeCapacity': {'min': 0, 'max': 0.92}
      },
      {
        'region': 'Central',
        'pH': {'min': 4.4, 'max': 7.7},
        'organicMatter': {'min': 0, 'max': 4.3},
        'totalNitrogen': {'min': 0, 'max': 0.37},
        'availablePhosphorus': {'min': 0, 'max': 9.80},
        'cationExchangeCapacity': {'min': 0, 'max': 0.24}
      },
      {
        'region': 'Eastern',
        'pH': {'min': 4.1, 'max': 7.8},
        'organicMatter': {'min': 0, 'max': 8.19},
        'totalNitrogen': {'min': 0, 'max': 0.37},
        'availablePhosphorus': {'min': 0, 'max': 3.48},
        'cationExchangeCapacity': {'min': 0, 'max': 9.62}
      },
      {
        'region': 'Greater Accra',
        'pH': {'min': 4.4, 'max': 9.5},
        'organicMatter': {'min': 0, 'max': 4},
        'totalNitrogen': {'min': 0, 'max': 0.32},
        'availablePhosphorus': {'min': 0, 'max': 6.62},
        'cationExchangeCapacity': {'min': 0, 'max': 9.28}
      },
      {
        'region': 'Northern',
        'pH': {'min': 4.1, 'max': 7.4},
        'organicMatter': {'min': 0, 'max': 6.74},
        'totalNitrogen': {'min': 0, 'max': 0.14},
        'availablePhosphorus': {'min': 0, 'max': 7.60},
        'cationExchangeCapacity': {'min': 0, 'max': 7.85}
      },
      {
        'region': 'Upper East',
        'pH': {'min': 4.1, 'max': 7.4},
        'organicMatter': {'min': 0.54, 'max': 6.74},
        'totalNitrogen': {'min': 0, 'max': 0.14},
        'availablePhosphorus': {'min': 0, 'max': 3.62},
        'cationExchangeCapacity': {'min': 0, 'max': 7.72}
      },
      {
        'region': 'Upper West',
        'pH': {'min': 4.1, 'max': 7.4},
        'organicMatter': {'min': 0.77, 'max': 6.74},
        'totalNitrogen': {'min': 0, 'max': 0.07},
        'availablePhosphorus': {'min': 0, 'max': 3.62},
        'cationExchangeCapacity': {'min': 0, 'max': 4.79}
      },
      {
        'region': 'Volta',
        'pH': {'min': 4.1, 'max': 7.8},
        'organicMatter': {'min': 0, 'max': 5.63},
        'totalNitrogen': {'min': 0, 'max': 0.02},
        'availablePhosphorus': {'min': 0, 'max': 6.62},
        'cationExchangeCapacity': {'min': 0, 'max': 9.28}
      },
      {
        'region': 'Western',
        'pH': {'min': 4.4, 'max': 6.7},
        'organicMatter': {'min': 0.19, 'max': 13.83},
        'totalNitrogen': {'min': 0, 'max': 0.37},
        'availablePhosphorus': {'min': 0, 'max': 0.26},
        'cationExchangeCapacity': {'min': 0, 'max': 1.21}
      },
    ];

    String resp = "An Error Occurred.";
    try {
      final CollectionReference soilCollection =
          FirebaseFirestore.instance.collection('RegionalSoilXtics');

      for (var data in soilData) {
        String region = data['region'];
        await soilCollection.doc(region).set({
          'pH': data['pH'],
          'organicMatter': data['organicMatter'],
          'totalNitrogen': data['totalNitrogen'],
          'availablePhosphorus': data['availablePhosphorus'],
          'cationExchangeCapacity': data['cationExchangeCapacity'],
        });
      }
      resp = "Success";
    } catch (error) {
      resp = error.toString();
    }

    return resp;
  }*/

  /// Saves the image specified by [imagePath] to local storage with the name [contact].jpg.
  ///
  /// The function creates a directory named "profile_images" in the external storage directory
  /// (on Android) or in the application support directory (on iOS), and saves the image
  /// with the specified contact name as a JPEG file in that directory.
  ///
  /// Parameters:
  ///   - imagePath: The path to the image file to be saved.
  ///   - contact: The name associated with the image. The image will be saved with this name as a JPEG file.
  ///
  /// Returns:
  ///   A [Future] containing the path to the saved image file.
  ///
  /// Throws:
  ///   - [UnsupportedError] if the platform is not supported.
  ///   - [Exception] if the directory path could not be obtained or if there was an issue saving the image.
  Future<String> saveToLocalStorage({
    required String imagePath,
    required String contact,
  }) async {
    const String dirName = "profile_images";
    late Directory dir;

    if (Platform.isAndroid) {
      dir =
          Directory('${(await getExternalStorageDirectory())!.path}/$dirName');
    } else if (Platform.isIOS) {
      dir = Directory(
          '${(await getApplicationSupportDirectory()).path}/$dirName');
    } else {
      await openAppSettings();
      throw UnsupportedError('Unsupported platform');
    }

    final PermissionStatus result = await (Platform.isAndroid
        ? (await DeviceInfoPlugin().androidInfo).version.sdkInt >= 33
            ? Permission.photos.request()
            : Permission.storage.request()
        : Permission.photos.request());

    if (result.isGranted) {
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }
      File selectedImageFile = File(imagePath);
      String destinationPath = '${dir.path}/$contact.jpg';
      await selectedImageFile.copy(destinationPath);

      return destinationPath;
    }

    throw Exception('Could not obtain directory path');
  }
}
