import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

import '../services/firebase_firestore_helper.dart';
import '../services/shared_preferences_helper.dart';
import 'home_page.dart';

class ChatScreen extends StatefulWidget {
  final String name, profileURL, username;
  const ChatScreen(
      {super.key,
      required this.name,
      required this.profileURL,
      required this.username});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? senderUserName,
      senderProfilePic,
      senderName,
      senderEmail,
      messageId,
      chatRoomID;
  Stream? messageStream;
  final TextEditingController _messageController = TextEditingController();

  getSharedPreferences() async {
    senderUserName = await SharedPreferenceHelper().getUserName();
    senderEmail = await SharedPreferenceHelper().getUseremail();
    senderName = await SharedPreferenceHelper().getUserName();
    senderProfilePic = await SharedPreferenceHelper().getUserPhoto();
    chatRoomID = createChatRoomIdbyUserName(widget.username, senderUserName!);
    setState(() {});
  }

  sendMessage(bool click) {
    if (_messageController.text.trim() != "") {
      String message = _messageController.text.trim();
      _messageController.text = "";
      DateTime currentTime = DateTime.now();
      String dateFormat = DateFormat('h:mma').format(currentTime);
      Map<String, dynamic> messageMap = {
        "message": message,
        "sender": senderName,
        "timeStamp": dateFormat,
        "time": FieldValue.serverTimestamp(),
        "picURL": senderProfilePic,
      };
      messageId ??= randomAlphaNumeric(10);

      FireStoreHelper()
          .saveMessageToFireStore(chatRoomID!, messageId!, messageMap)
          .then((value) {
        Map<String, dynamic> recentMessageMap = {
          "recentMessage": message,
          "recentMessageTimeStamp": dateFormat,
          "recentMessageTime": FieldValue.serverTimestamp(),
          "recentMessageSentBy": senderName,
        };
        FireStoreHelper()
            .saveRecentMessageToFireStore(chatRoomID!, recentMessageMap);
        if (click) {
          messageId = null;
        }
      });
    }
    setState(() {});
  }

  createChatRoomIdbyUserName(String user1, String user2) {
    if (user1.substring(0, 1).codeUnitAt(0) >
        user2.substring(0, 1).codeUnitAt(0)) {
      return "${user2}_$user1";
    } else {
      return "${user1}_$user2";
    }
  }

  getAndSetMessages() async {
    messageStream = await FireStoreHelper().getChatMessages(chatRoomID);
    setState(() {});
  }

  onLoad() async {
    await getSharedPreferences();
    await getAndSetMessages();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: const Color(0xffE6DBD0),
      body: Column(
        children: [
          const SafeArea(child: Text("")),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            decoration: const BoxDecoration(color: Colors.red),
            child: Row(children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) {
                    return const HomeScreen();
                  }));
                },
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(
                width: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  widget.profileURL,
                  height: 40,
                  width: 40,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(widget.name), Text(widget.username)],
              )
            ]),
          ),
          Expanded(
            child: Stack(
              children: [
                chatMessage(),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {});
                        },
                        controller: _messageController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a message",
                            prefixIcon:
                                _messageController.text.trim().isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _messageController.clear();
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.clear))
                                    : null,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                sendMessage(true);
                              },
                            )),
                      ),
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

  Widget chatMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: StreamBuilder(
          stream: messageStream,
          builder: (context, AsyncSnapshot snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    padding: const EdgeInsets.all(9),
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      return chatMessageTile(
                          message: ds['message'],
                          sender: senderName == ds['sender']);
                    })
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          }),
    );
  }

  Widget chatMessageTile({required String message, required bool sender}) {
    return Row(
      mainAxisAlignment:
          sender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            decoration: BoxDecoration(
                color: sender ? Colors.blue : Colors.blueAccent,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(24),
                    topRight: const Radius.circular(24),
                    bottomLeft: sender
                        ? const Radius.circular(24)
                        : const Radius.circular(0),
                    bottomRight: sender
                        ? const Radius.circular(0)
                        : const Radius.circular(24))),
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}
