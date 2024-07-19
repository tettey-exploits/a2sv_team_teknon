/* import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:farmnets/database/farmer_db.dart';
import 'package:farmnets/models/farmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:farmnets/auth/auth_service.dart';
import '../../components/services/farmer_location.dart';
import '../../components/services/get_climate_patterns.dart';
import '../../components/services/save_profile.dart';
import '../ext_officer/officer_login.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  List<String> numbers() => ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  bool _isWelcomeNotePlaying = false;
  bool _confirmDone = false;
  final player = AudioPlayer();
  bool speechEnabled = false;
  String _results = "";
  String _reply = "";
  final String _password = "Password";
  String allInWords = "";
  final SpeechToText _speechToText = SpeechToText();

  bool _nameMention = false;
  String userName = "";
  final authService = AuthService();

  final location = LocationService(dotenv.env['LOCATION_API']!);
  final climatePattern = ClimatePattern(apiKey: dotenv.env['LOCATION_API']!);
  final FarmerDB localDb = FarmerDB();

  bool _isPlayingRecording = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      initSpeech();
    }
    // TODO: consider not calling this over here
    playWelcomeNote();
  }

  void initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  // Possible fix
  //TODO: check this
  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // Background image with opacity
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/app_images/kente.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.05),
                    BlendMode.dstATop,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Colors.white,
                  ],
                ),
              ),
            ),

            // Content of the screen
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(155),
                        child: Image.asset(
                          'assets/app_images/farmer_image.png',
                          width: 310,
                          height: 310,
                        ),
                      ),
                    ),
                  ),
                  Text(_results,
                      style: const TextStyle(
                        fontSize: 35,
                      )),
                  const SizedBox(height: 80),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: _isPlayingRecording
                          ? ClipOval(
                              child: Image.asset(
                                'assets/app_images/siri.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : FloatingActionButton(
                              onPressed: startListening,
                              tooltip: 'listen',
                              backgroundColor: Colors.black,
                              //Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Icon(
                                _speechToText.isListening
                                    ? Icons.mic
                                    : Icons.mic_off,
                                color: _isWelcomeNotePlaying
                                    ? Colors.grey
                                    : Colors.white,
                                size: 35,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OfficerLogin()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.secondary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Extension officer",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> playWelcomeNote() async {
    setState(() {
      _isWelcomeNotePlaying = true;
      _isPlayingRecording = true;
    });
    String audioPath = "app_audio/welcome_audio.mp3";
    if (player.state == PlayerState.stopped) {
      await player.play(AssetSource(audioPath));
    } else {
      await player.resume();
    }

    player.onPlayerComplete.listen((_) {
      setState(() {
        _isWelcomeNotePlaying = false;
        _isPlayingRecording = false;
      });
    });
  }

  void startListening() async {
    if (!_nameMention) {
      if (!_confirmDone) {
        await _speechToText.listen(onResult: _onSpeechResult);
        setState(() {});
      } else if (_confirmDone) {
        await _speechToText.listen(onResult: _confirmationResult);
      }
      setState(() {});
    } else if (_nameMention) {
      if (_confirmDone) {
        await _speechToText.listen(onResult: _nameSpeechResult);
      }
    }
  }

// for processing the said number
  void _processListening() async {
    allInWords = "";
    for (int i = 0; i < _results.length; i++) {
      if (numbers().contains(_results[i])) {
        allInWords += _results[i];
      }
    }

    if (allInWords.length == 10) {
      confirmationNote();

      setState(() {
        _confirmDone = true;
      });
    } else {
      mistakeNote();
      setState(() {
        _confirmDone = false;
      });
    }
  }

  void _answerConfirmation() async {
    if (_reply == "Annie") {
      setState(() {
        allInWords = "$allInWords@gmail.com";
      });
      if (mounted) {
        signupOrLogin(context);
      }
    } else {
      mistakeNote();
      setState(() {
        _confirmDone = false;
      });
    }
  }

  void _confirmationResult(result) {
    setState(() {
      _reply = result.recognizedWords;
    });

    if (_speechToText.isNotListening) {
      _answerConfirmation();
    }
  }

  void _onSpeechResult(result) {
    setState(() {
      _results = result.recognizedWords;
    });
    if (_speechToText.isNotListening) {
      // Process the recognized speech
      _processListening();
    }
  }

  Future<void> confirmationNote() async {
    setState(() {
      _isPlayingRecording = true;
    });
    String audioPath = "app_audio/confirmation_audio.mp3";
    await player.play(AssetSource(audioPath));
    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingRecording = false;
      });
    });
  }

  Future<void> mistakeNote() async {
    setState(() {
      _isPlayingRecording = true;
    });
    String audioPath = "app_audio/mistake_audio.mp3";
    await player.play(AssetSource(audioPath));
    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingRecording = false;
      });
    });
  }

  Future<void> askForName() async {
    setState(() {
      _isPlayingRecording = true;
    });
    String audioPath = "app_audio/name_audio.mp3";
    await player.play(AssetSource(audioPath));
    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingRecording = false;
      });
    });
  }

  void signupOrLogin(BuildContext context) async {
    try {
      // Show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return const Center(child: CircularProgressIndicator());
          });

      UserCredential? result =
          await authService.signInWithEmailPassword(allInWords, _password);
      // Pop the loading circle
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result == null) {
        log("User account not found\n");
        // Play name note
        setState(() {
          _nameMention = true;
        });
        askForName();
      }
    } catch (e) {
      log('Error signing in: $e');
      // Pop the loading circle
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _nameSpeechResult(result) async {
    setState(() {
      userName = result.recognizedWords;
    });

    if (_speechToText.isNotListening) {
      if (userName.isNotEmpty) {
        try {
          // Show loading circle
          showDialog(
              context: context,
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              });
          String cityName = await location.fetchCity();

          await saveProfile(userName, allInWords, cityName, 0);

          await authService.signUpWithEmailPassword(allInWords, _password);
          // Pop the loading circle
          if (mounted) {
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (mounted) {
            Navigator.of(context).pop();
          }
          if (kDebugMode) print('Error signing up: $e');
        }
      }
    }
  }

  Future<void> saveProfile(
      String name, String email, String location, int rating) async {
    String farmerProfileStatus = await SaveProfile().saveToFirestoreFarmer(
      name: name,
      contact: email,
      location: location,
      rating: rating,
    );

    await localDb.create(name: name, contact: email, location: location);
    List<Farmer> fetchedData = await localDb.fetchAll();
    for (var farmer in fetchedData) {
      if (kDebugMode) print(farmer.name);
    }
    log("Save farmer profile status = $farmerProfileStatus");
  }
}
 */