import 'package:avatar_glow/avatar_glow.dart';
import 'package:voicegpt/api_services.dart';
import 'package:voicegpt/chat_model.dart';
import 'package:voicegpt/colors.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  SpeechToText speechToText = SpeechToText();
  TextToSpeech tts = TextToSpeech();
  var text = 'Hold the button and start speaking';
  var isListening = false;
  final List<ChatMessage> messages = [];

  var scrollController = ScrollController();

  scrollMethod() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75,
        animate: isListening,
        duration: Duration(milliseconds: 2000),
        glowColor: bgColor,
        repeatPauseDuration: Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechToText.listen(onResult: (result) {
                    setState(() {
                      text = result.recognizedWords;
                    });
                  });
                });
              }
            }
          },
          onTapUp: (details) async {
            setState(() {
              isListening = false;
            });
            speechToText.stop();

            messages.add(
              ChatMessage(text: text, type: ChatMessageType.user),
            );
            var msg = await ApiServices.sendMessage(text);
            setState(() {
              messages.add(
                ChatMessage(text: msg, type: ChatMessageType.bot),
              );
            });
            tts.speak(msg);
            _scrollDown();
          },
          child: CircleAvatar(
            backgroundColor: Colors.green.shade600,
            radius: 35,
            child: Icon(
              isListening ? Icons.mic_sharp : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        leading: Icon(
          Icons.adb_outlined,
          color: Colors.white,
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0.0,
        title: Text(
          'ChatGPT AI',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        physics: BouncingScrollPhysics(),
        child: Container(
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height *0.7,
          // alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          // margin: EdgeInsets.only(bottom: 150),
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isListening ? Colors.black87 : Colors.black54,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.6,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: chatBgColor,
                  ),
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: scrollController,
                      itemCount: messages.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        var chat = messages[index];

                        return chatBubble(
                          chatText: chat.text != null ? chat.text : '',//changed
                          type: chat.type,
                        );
                      }),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget chatBubble({required chatText, required ChatMessageType? type}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: bgColor,
          child: type == ChatMessageType.bot
              ? Image.asset(
                  'assets/icon.png',
                )
              : Icon(
                  Icons.person,
                  color: Colors.white,
                ),
        ),
        SizedBox(
          width: 12,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: type == ChatMessageType.bot ? bgColor : Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Text(
              chatText,
              style: TextStyle(
                fontWeight: type == ChatMessageType.bot
                    ? FontWeight.w600
                    : FontWeight.w400,
                fontSize: 15,
                color: type == ChatMessageType.bot ? textColor : chatBgColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
