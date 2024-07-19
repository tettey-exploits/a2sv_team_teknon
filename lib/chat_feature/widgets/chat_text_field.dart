import 'package:farmnets/themes/light_mode.dart';
import 'package:flutter/material.dart';

class ChatTextField extends StatelessWidget {
  final String hintText;
  //final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  const ChatTextField({
    super.key,
    required this.hintText,
    //required this.obscureText,
    required this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    double screenHeight = queryData.size.height;
    //double screenWidth = queryData.size.width;

    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              //minWidth: 100,
              //maxWidth: 120,
              minHeight: screenHeight / 34.65,
              maxHeight: screenHeight / 6.45,
            ),
            child: Scrollbar(
              child: TextField(
                cursorColor: tabColor,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                //obscureText: obscureText,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                      top: 2.0, left: 13.0, right: 13.0, bottom: 2.0,),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary),
                        borderRadius: BorderRadius.circular(20.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(20.0),
                  ),
                  fillColor: whiteColor,
                  filled: true,
                  hintText: hintText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
