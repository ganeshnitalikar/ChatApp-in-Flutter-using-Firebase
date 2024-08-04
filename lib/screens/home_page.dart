// ignore_for_file: use_build_context_synchronously, unnecessary_string_escapes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/signin_screen.dart';
import '../services/firebase_firestore_helper.dart';
import '../services/shared_preferences_helper.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? myName, myProfilePic, myUserName, myEmail;
  bool _isVisible = false;
  bool search = false;
  Stream? chats;

  var queryResultSet = [];
  var tempSearchStore = [];

  getSharedPreferences() async {
    myName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUseremail();
    myProfilePic = await SharedPreferenceHelper().getUserPhoto();
    myUserName = await SharedPreferenceHelper().getUserName();
    setState(() {});
  }

  onLoad() async {
    await getSharedPreferences();
    chats = await FireStoreHelper().getChatRooms();
    setState(() {});
  }

  createChatRoomIdbyUserName(String user1, String user2) {
    if (user1.substring(0, 1).codeUnitAt(0) >
        user2.substring(0, 1).codeUnitAt(0)) {
      return "$user2\_$user1";
    } else {
      return "$user1\_$user2";
    }
  }

  startSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    setState(() {
      search = true;
    });

    String capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.isEmpty && value.length == 1) {
      FireStoreHelper().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          queryResultSet.add(docs.docs[i].data());
        }
      });
    } else {
      tempSearchStore = [];
      for (var element in queryResultSet) {
        if (element['Username'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      }
    }
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
      backgroundColor: Colors.red.shade300,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Chatter",
          style: TextStyle(
              color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              },
              icon: const Icon(Icons.logout)),
          IconButton(
              onPressed: () {
                setState(() {
                  _isVisible = !_isVisible;
                  setState(() {
                    search = !search;
                  });
                });
              },
              icon: const Icon(Icons.search))
        ],
        backgroundColor: Colors.transparent,
      ),
      body: Column(children: [
        Visibility(
          visible: _isVisible,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(30),
              child: TextField(
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    startSearch(value.toUpperCase());
                  } else {
                    queryResultSet = [];
                    tempSearchStore = [];
                  }
                },
                onTap: () => FocusScope.of(context).unfocus(),
                controller: _searchController,
                decoration: InputDecoration(
                    hintText: "Search User",
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    suffixIcon: search
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: const Icon(Icons.cancel))
                        : null),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              width: mq.width,
              decoration: const BoxDecoration(
                  color: Colors.white30, //add almond color here
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                children: [
                  search
                      ? ListView(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          primary: false,
                          shrinkWrap: true,
                          children: tempSearchStore.map((element) {
                            return myCard(data: element);
                          }).toList(),
                        )
                      : chatRoomWidget(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget chatRoomWidget() {
    return StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? Expanded(
                  child: SizedBox(
                    child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          return ChatRoomTiles(
                            lastMessage: ds['recentMessage'],
                            chatRoomId: ds.id,
                            myUserName: ds['Username'],
                            time: ds["recentMessageTimeStamp"],
                          );
                        }),
                  ),
                )
              : Center(
                  child: Text("Some text"),
                );
        });
  }

  Widget myCard({
    required var data,
  }) {
    return GestureDetector(
      onTap: () async {
        //navigate to the corresponding chat
        setState(() {
          search = false;
        });
        var chatRoomId =
            createChatRoomIdbyUserName(myUserName!, data['Username']);
        Map<String, dynamic> chatRoomIDMap = {
          'users': [myUserName, data["Usesrname"]],
        };

        await FireStoreHelper().createChatRoom(chatRoomId, chatRoomIDMap);
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ChatScreen(
              name: data['Name'],
              profileURL: data['Photo'],
              username: data['Username']);
        }));
      },
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  data['Photo'],
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['Name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800),
                    ),
                    Text(
                      data['Username'],
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatRoomTiles extends StatefulWidget {
  final String lastMessage, chatRoomId, myUserName, time;
  const ChatRoomTiles({
    super.key,
    required this.lastMessage,
    required this.chatRoomId,
    required this.myUserName,
    required this.time,
  });

  @override
  State<ChatRoomTiles> createState() => _ChatRoomTilesState();
}

class _ChatRoomTilesState extends State<ChatRoomTiles> {
  String profilePicURL = "", name = "", username = "", id = "";
  getUserInfo() async {
    username =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.myUserName, "");
    QuerySnapshot querySnapshot =
        await FireStoreHelper().getUserByUserName(username);

    name = "${querySnapshot.docs[0]["Name"]}";
    profilePicURL = "${querySnapshot.docs[0]["Photo"]}";
    id = "${querySnapshot.docs[0]["Id"]}";
    setState(() {});
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            profilePicURL == ""
                ? const CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      profilePicURL,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800),
                  ),
                  Text(
                    widget.lastMessage,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
            ),
            const Spacer(),
            Text(widget.time)
          ],
        ),
      ),
    );
  }
}
