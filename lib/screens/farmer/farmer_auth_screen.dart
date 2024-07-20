import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:farmnets/database/farmer_db.dart';
import 'package:farmnets/models/farmer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:farmnets/auth/auth_service_farmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/farmer_location.dart';
import '../../services/get_climate_patterns.dart';
import '../../services/save_profile.dart';
import '../../screens/ext_officer/officer_login.dart';
import 'package:telephony/telephony.dart';
//import '../../screens/farmer/farmer_home_screen.dart';

class FarmerAuthScreen extends StatefulWidget {
  const FarmerAuthScreen({super.key});

  @override
  State<FarmerAuthScreen> createState() => _FarmerAuthScreenState();
}

class _FarmerAuthScreenState extends State<FarmerAuthScreen> {
  List<String> numbers() => ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  bool _isWelcomeNotePlaying = false;
  bool _confirmDone = false;

  // (A) bug fix
  //final player = AudioPlayer();
  late final AudioPlayer player;
  bool speechEnabled = false;
  String _results = "";
  String _reply = "";
  String allInWords = "";
  final SpeechToText _speechToText = SpeechToText();
  bool _nameMention = false;
  String _farmerName = "";
  final TextEditingController _otpController = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();
  final Telephony telephony = Telephony.instance;

  final location = LocationService(dotenv.env['LOCATION_API']!);
  final climatePattern = ClimatePattern(apiKey: dotenv.env['LOCATION_API']!);
  final FarmerDB localDb = FarmerDB();
  bool _isLoggingIn = false;
  bool _isPlayingAudio = false;

  void listenToIncomingSMS(BuildContext context) {
    log("Listening to sms.");
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          // Handle message
          log("sms received : ${message.body}");

          // verify if we are reading the correct sms or not

          if (message.body != null &&
              message.body!.contains("farmnets-v2-26b95")) {
            String otpCode = message.body!.substring(0, 6);
            setState(() {
              _otpController.text = otpCode;
              // wait for 3 sec and then press handle submit
              Future.delayed(const Duration(seconds: 3), () {
                handleSubmit(context);
              });
            });
          }
        },
        listenInBackground: false);
  }

  // handle after otp is submitted
  Future<void> handleSubmit(BuildContext context) async {
    if (_formKey1.currentState!.validate()) {
      String cityName = await location.fetchCity();
      int initialRating = 0;

      AuthServiceFarmer.loginWithOtp(
        otp: _otpController.text,
        username: _farmerName,
        location: cityName,
        rating: initialRating,
      ).then((value) async {
        if (value == "Success") {
          if (mounted) {
            //Navigator.pop(context);
            log("OTP sign-in successful");

            await _saveProfileLocalDB(
                _farmerName, allInWords, cityName, initialRating);
            //await saveProfile(_farmerName, allInWords, cityName, 0);
            //log("Done saving profile details");
          }
        } else {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  void initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    if (mounted) {
      initSpeech();
    }
    playWelcomeAudio();
  }

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
              child: SingleChildScrollView(
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
                        child: _isPlayingAudio
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
                            builder: (context) => const OfficerLogin(),
                          ),
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
                          "${AppLocalizations.of(context)!.extensionOfficer}?",
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
            ),
            if (_isLoggingIn)
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

  Future<void> playWelcomeAudio() async {
    setState(() {
      _isWelcomeNotePlaying = true;
      _isPlayingAudio = true;
    });
    String audioPath = "app_audio/welcome_audio.mp3";
    // TODO: fix error on logout
    if (player.state == PlayerState.stopped) {
      await player.play(AssetSource(audioPath));
    } else {
      await player.resume();
    }

    player.onPlayerComplete.listen((_) {
      setState(() {
        _isWelcomeNotePlaying = false;
        _isPlayingAudio = false;
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
      confirmationAudio();

      setState(() {
        _confirmDone = true;
      });
    } else {
      playMistakeAudio();
      setState(() {
        _confirmDone = false;
      });
    }
  }

  void _answerConfirmation() async {
    if (_reply == "Annie") {
      setState(() {
        allInWords = "+233${allInWords.substring(1)}";
      });
      setState(() {
        _nameMention = true;
      });
      askForName();
    } else {
      playMistakeAudio();
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

  Future<void> confirmationAudio() async {
    setState(() {
      _isPlayingAudio = true;
    });
    String audioPath = "app_audio/confirmation_audio.mp3";
    await player.play(AssetSource(audioPath));
    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingAudio = false;
      });
    });
  }

  Future<void> playMistakeAudio() async {
    setState(() {
      _isPlayingAudio = true;
    });
    String audioPath = "app_audio/mistake_audio.mp3";
    await player.play(AssetSource(audioPath));
    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingAudio = false;
      });
    });
  }

  Future<void> askForName() async {
    setState(() {
      _isPlayingAudio = true;
    });
    String audioPath = "app_audio/name_audio.mp3";
    await player.play(AssetSource(audioPath));
    player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingAudio = false;
      });
    });
  }

  Future<void> _nameSpeechResult(result) async {
    String gottenName = result.recognizedWords;
    setState(() {
      _farmerName = gottenName;
    });

    if (_speechToText.isNotListening) {
      if (_farmerName.isNotEmpty) {
        try {
          setState(() {
            // Show loading circle
            _isLoggingIn = true;
          });

          AuthServiceFarmer.sentOtp(
              phone: allInWords,
              errorStep: () =>
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.errorSendingOTP,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  )),
              nextStep: () {
                // start listening for otp
                listenToIncomingSMS(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.otpVerification),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.enter6DigitOTP),
                        const SizedBox(
                          height: 12,
                        ),
                        Form(
                          key: _formKey1,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _otpController,
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .enterPhoneNumber,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(32))),
                            validator: (value) {
                              if (value!.length != 6) {
                                return AppLocalizations.of(context)!.invalidOTP;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.amber,
                          ),
                          onPressed: () {
                            handleSubmit(context);
                            // TODO: remove if not testing
                            // This pops the AlertDialog immediately after calling the handleSubmit method
                            // This was added because we'll be using the test numbers.
                            // possible bug: might not be able to retrieve code sent to real user's number
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.submitOTP)),
                    ],
                  ),
                );
              });
        } catch (e) {
          // Pop loading circle
          setState(() {
            _isLoggingIn = false;
          });
          log('Error signing up: $e');
        }
      } else {
        log("No name gotten");
      }
    }
  }

  Future<void> _saveProfileLocalDB(
      String name, String email, String location, int rating) async {
    /* String farmerProfileStatus = await SaveProfile().saveToFirestoreFarmer(
      name: name,
      contact: email,
      location: location,
      rating: rating,
    );*/

    await localDb.create(name: name, contact: email, location: location);
    List<Farmer> fetchedData = await localDb.fetchAll();
    for (var farmer in fetchedData) {
      log("Names fetched from local DB: ${farmer.name}");
    }
  }
}
