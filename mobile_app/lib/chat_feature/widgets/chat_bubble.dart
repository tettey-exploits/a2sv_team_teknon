import 'package:audioplayers/audioplayers.dart';
import 'package:farmnets/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../components/audio_controller.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String? imageUrl;
  final String? audioUrl;
  final DateTime timeStamp;
  final bool? isTranslatedText;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.imageUrl,
    this.audioUrl,
    required this.timeStamp,
    this.isTranslatedText,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  // TODO: take these out
  /*final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;*/

  late final AudioController _audioController;
  //final AudioController _audioController = Get.put(AudioController());

  @override
  void initState() {
    _audioController = AudioController();
    _audioController.onInit();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _audioController.onClose();
    // TODO: implement dispose
    super.dispose();
  }

  /*@override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl!));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    String formattedTimeStamp = DateFormat('hh:mm a').format(widget.timeStamp);

    return Container(
      decoration: BoxDecoration(
        color: widget.isCurrentUser ? senderMessageColor : whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Image.network(
                widget.imageUrl!,
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
          if (widget.audioUrl != null)
            Obx(() {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_audioController.isRecordPlaying
                        ? Icons.pause
                        : Icons.play_arrow),
                    onPressed: () {
                      _audioController.onPressedPlayButton(
                          widget.hashCode, widget.audioUrl);
                    },
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 1,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      //overlayShape: const RoundSliderOverlayShape(overlayRadius: 6),
                    ),
                    child: Slider(
                      value: _audioController.currentDuration.value.toDouble() /
                          1000000, // Convert microseconds to seconds
                      max: _audioController.totalDuration.value.toDouble() /
                          1000000, // Convert microseconds to seconds
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await _audioController.audioPlayer.seek(position);
                      },
                    ),
                  ),
                  /*Text(
                    "${Duration(microseconds: _audioController.currentDuration.value).inMinutes}:${(Duration(microseconds: _audioController.currentDuration.value).inSeconds % 60).toString().padLeft(2, '0')} / ${Duration(microseconds: _audioController.totalDuration.value).inMinutes}:${(Duration(microseconds: _audioController.totalDuration.value).inSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 12),
                  ),*/
                ],
              );
            }),
          if (widget.message.isNotEmpty)
            Text(
              widget.message,
              style: const TextStyle(fontSize: 15),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              formattedTimeStamp,
              style: const TextStyle(fontSize: 10),
            ),
          )
        ],
      ),
    );
  }
}
