import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:mindbloom/journel/journal.dart';
import 'package:android_intent_plus/android_intent.dart';

class Bot extends StatefulWidget {
  const Bot({Key? key}) : super(key: key);

  @override
  _BotState createState() => _BotState();
}

class _BotState extends State<Bot> {
  final ScrollController _scrollController = ScrollController();

  bool showActionButtons = false;
  bool isBotTyping = false;

  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile(
      path: "assets/dialog_flow_auth.json",
    ).then((instance) => dialogFlowtter = instance);
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      addMessage(Message(text: DialogText(text: [text])), true);
      isBotTyping = true;
    });

    _controller.clear();

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    final String botReply =
        response.message?.text?.text?.first.toLowerCase().trim() ?? "";

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      isBotTyping = false;

      if (response.message != null) {
        addMessage(response.message!);

        if (botReply.contains("ok let's do that for you") ||
            botReply.contains("ok lets do that for you") ||
            botReply.startsWith("ok")) {
          showActionButtons = true;
        } else {
          showActionButtons = false;
        }
      }
    });
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A5DC7), Color(0xFF957DAD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.spa, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'MindBloom',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MessagesScreen(
              messages: messages,
              isBotTyping: isBotTyping,
              scrollController: _scrollController,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFF7A5DC7).withOpacity(0.2),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Color(0xFF302B4E),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () => sendMessage(_controller.text),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7A5DC7), Color(0xFF957DAD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (showActionButtons)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final intent = AndroidIntent(
                        action: 'android.intent.action.MUSIC_PLAYER',
                      );
                      intent.launch();
                    },
                    icon: Icon(Icons.music_note),
                    label: Text("Music"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7A5DC7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showActionButtons = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JournalPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.book),
                    label: Text("Journal"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7A5DC7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  final List messages;
  final ScrollController scrollController;
  final bool isBotTyping;

  const MessagesScreen({
    Key? key,
    required this.messages,
    required this.scrollController,
    required this.isBotTyping,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      itemCount: messages.length + (isBotTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isBotTyping) {
          return _typingIndicator();
        }

        bool isUser = messages[index]['isUserMessage'];
        String text = messages[index]['message'].text.text[0];

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUser)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage("assets/bot.png"),
                  ),
                if (!isUser) SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  constraints: BoxConstraints(maxWidth: w * 0.75),
                  decoration: BoxDecoration(
                    color:
                        isUser
                            ? Color(0xFF9F79EE).withOpacity(0.85)
                            : Color(0xFF6A5ACD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                if (isUser) SizedBox(width: 8),
                if (isUser)
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage("assets/sadness.png"),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage("assets/bot_avatar.png"),
            ),
            SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Color(0xFF5C5470),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dot(),
                  SizedBox(width: 4),
                  _dot(delay: 200),
                  SizedBox(width: 4),
                  _dot(delay: 400),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 0.3, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
        ),
      ),
      onEnd: () {},
    );
  }
}
