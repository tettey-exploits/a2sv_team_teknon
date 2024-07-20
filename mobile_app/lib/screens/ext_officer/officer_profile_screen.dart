import 'dart:io';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import '../../database/ext_officer_db.dart';

class OfficerProfileScreen extends StatefulWidget {
  final String officerName;
  final String email;
  final String imagePath;

  const OfficerProfileScreen({super.key, required this.officerName, required this.email, required this.imagePath});

  @override
  State<OfficerProfileScreen> createState() => _OfficerProfileScreenState();
}

class _OfficerProfileScreenState extends State<OfficerProfileScreen> {
  String get officerName => widget.officerName;
  String get email => widget.email;
  String get imagePath => widget.imagePath;
 // final localDb = ExtensionOfficerDB();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: imagePath != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: FileImage(File(imagePath!)),
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage: AssetImage(
                                'assets/app_images/no_profile.png',
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40,),
              buildTextField("Name", "Enter your Name here",
                  officerName != null ? officerName! : "Akua"),
              const SizedBox(height: 20,),
              buildTextField("Email", "Enter your Email here",
                  email != null ? email! : "akua@gmail.com"),
              const SizedBox(height: 40),
              Center(
                child: OutlinedButton(
                    onPressed: () {


                    },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.secondary),),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white
                      ),
                    )

                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, String initialText) {
    TextEditingController controller = TextEditingController(text: initialText);
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 5),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          labelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,

          ),
        ),
      ),
    );
  }

 /* Future<void> getOfficerDetails({required String officerEmail}) async {
    if (kDebugMode) {
      print(officerEmail);
    }
    try {
      final details = await localDb.fetchByEmail(officerEmail);
      setState(() {
        _name = details.name;
        _email = details.email;
        _imagePath = details.imagePath;
      });
      if (kDebugMode) {
        print("Officer details as follow: ");
        print("Name: ${details.name}");
        print("Email: ${details.email}");
        print("Image: ${details.imagePath}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting details: $e");
      }
    }
  }*/
}
