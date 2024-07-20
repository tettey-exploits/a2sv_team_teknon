import 'dart:developer';
import 'dart:io';

import 'package:farmnets/auth/auth_service_officer.dart';
import 'package:farmnets/services/get_climate_patterns.dart';
import 'package:farmnets/database/ext_officer_db.dart';
import 'package:farmnets/models/ext_officer.dart';
import 'package:farmnets/services/save_profile.dart';
import 'package:farmnets/screens/ext_officer/officer_home_screen.dart';
import 'package:farmnets/widgets/form_container_widget.dart';
import 'package:farmnets/widgets/toast_widget.dart';
import 'package:farmnets/themes/light_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/farmer_location.dart';
import 'officer_login.dart';

class OfficerSignUp extends StatefulWidget {
  const OfficerSignUp({super.key});

  @override
  State<OfficerSignUp> createState() => _OfficerSignUpState();
}

class _OfficerSignUpState extends State<OfficerSignUp> {
  //final FirebaseAuthServiceOfficer _auth = FirebaseAuthServiceOfficer();
  final authService = AuthServiceOfficer();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool passwordsMatch = true;
  final location = LocationService(dotenv.env['LOCATION_API']!);
  final climatePattern = ClimatePattern(apiKey: dotenv.env['LOCATION_API']!);
  final ExtensionOfficerDB localDb = ExtensionOfficerDB();
  String? selectedImagePath;
  bool _isSigningUp = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordsMatch);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Responsive design
    //double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
          Theme.of(context).colorScheme.secondary,
          Colors.white,
        ],
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 68,
                    backgroundColor: Colors.black,
                    child: Stack(
                      children: [
                        selectedImagePath != null
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage:
                                    FileImage(File(selectedImagePath!)),
                              )
                            : const CircleAvatar(
                                radius: 80,
                                backgroundImage: AssetImage(
                                    'assets/app_images/no_profile.png'),
                              ),
                        Positioned(
                          bottom: -5,
                          left: 85,
                          child: IconButton(
                            onPressed: () {
                              showImagePickerOption(context);
                            },
                            icon: const Icon(Icons.add_a_photo,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Create An Account",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                        const Text("Upload an image and fill the spaces below",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 14,
                            )),
                        const SizedBox(height: 20),
                        FormContainerWidget(
                          hintText: "Full Name",
                          isPasswordField: false,
                          controller: _fullNameController,
                        ),
                        //const SizedBox(height: 7),
                        FormContainerWidget(
                          hintText: "Email",
                          isPasswordField: false,
                          controller: _emailController,
                        ),
                        //const SizedBox(height: 7),
                        FormContainerWidget(
                          hintText: "Password",
                          isPasswordField: true,
                          controller: _passwordController,
                        ),
                        Visibility(
                          visible: !passwordsMatch,
                          child: const Text("Passwords do no match!",
                              style: TextStyle(
                                  color: errorRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                        FormContainerWidget(
                          hintText: "Confirm Password",
                          isPasswordField: true,
                          controller: _confirmPasswordController,
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: GestureDetector(
                            onTap: () {
                              if (selectedImagePath != null) {
                                _signUp();
                              } else {
                                _promptAddPhoto();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 70,
                              decoration: BoxDecoration(
                                color: selectedImagePath != null
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  "SIGN UP",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15)),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OfficerLogin(),
                                    ),
                                    (route) => false);
                              },
                              child: Text(
                                "LOGIN",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isSigningUp)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    String fullName = _fullNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Show loading circle
    setState(() {
      _isSigningUp = true;
    });

    String cityName = await location.fetchCity();
    int initialRating = 0;
    late Uint8List imageBytes;

    if (selectedImagePath != null) {
      File imageFile = File(selectedImagePath!);
      imageBytes = await imageFile.readAsBytes();

    }

    UserCredential? result;
    try {
      showToast(message: 'Please wait');
      result = await authService.signUpWithEmailPassword(
        email: email,
        password: password,
        username: fullName,
        location: cityName,
        rating: initialRating,
        imageFile: imageBytes,
      );
    } catch (e) {
      if (mounted) {
        showToast(message: 'Failed to create account: $e');
      }
    }
    if (result != null) {
      // Save profile to local storage on sign-up success
      await saveProfile(
          fullName, email, cityName, initialRating, selectedImagePath!);
    } else {
      if (mounted) {
        showToast(message: 'An error occurred.');
      }
      // Pop the loading circle
      setState(() {
        _isSigningUp = false;
      });
      return;
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const OfficerHomeScreen(),
          ),
          (route) => false);
    }
  }

  void _checkPasswordsMatch() {
    setState(() {
      passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _promptAddPhoto() {
    showToast(message: 'Please add a photo for profile.');
  }

  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      selectedImagePath = returnImage.path;
    });
    if (kDebugMode) print(selectedImagePath);
    if (mounted) {
      Navigator.of(context).pop(); //close the model sheet
    }
  }

  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImagePath = returnImage.path;
    });
    if (kDebugMode) print(selectedImagePath);
    if (mounted) {
      Navigator.of(context).pop();
    }
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
                      onTap: _pickImageFromGallery,
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take Photo'),
                      onTap: _pickImageFromCamera,
                    )
                  ],
                ),
              ));
        });
  }

  Future<void> saveProfile(String name, String email, String location,
      int rating, String imagePath) async {
    String savedImagePath = await SaveProfile()
        .saveToLocalStorage(imagePath: imagePath, contact: email);
    log("Image saved at = $savedImagePath");

    try {
      localDb.create(
          name: name,
          email: email,
          location: location,
          imagePath: savedImagePath);
    } catch (e) {
      log("Error saving to local DB: $e");
    }

    List<ExtensionOfficer> fetchedData = await localDb.fetchAll();
    for (var officer in fetchedData) {
      if (kDebugMode) print(officer.name);
    }
  }

/*Future<String> saveProfile(String name, String email, String location,
      int rating, String imagePath) async {
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();

    String response = await SaveProfile().saveToFirestoreOfficer(
        name: name,
        contact: email,
        location: location,
        rating: rating,
        imageFile: imageBytes);

    //if (kDebugMode) print("Firestore upload status = $response");

    String savedImagePath = await SaveProfile()
        .saveToLocalStorage(imagePath: imagePath, contact: email);
    if (kDebugMode) print("Image saved at = $savedImagePath");

    try {
      localDb.create(
          name: name,
          email: email,
          location: location,
          imagePath: savedImagePath);
    } catch (e) {
      if (kDebugMode) {
        print("Error saving to local DB: $e");
      }
    }

    List<ExtensionOfficer> fetchedData = await localDb.fetchAll();
    for (var officer in fetchedData) {
      if (kDebugMode) print(officer.name);
    }

    return response;
  }*/
}
