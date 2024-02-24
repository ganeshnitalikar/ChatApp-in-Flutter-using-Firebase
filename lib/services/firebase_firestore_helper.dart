import 'package:chat_app/services/shared_preferences_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreHelper {
  Future addUserDetails(Map<String, dynamic> userData, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userData);
  }

  Future<QuerySnapshot> getUserbyEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where("Email", isEqualTo: email)
        .get();
  }

  Future<QuerySnapshot> search(String username) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('SearchKey', isEqualTo: username.substring(0, 1).toUpperCase())
        .get();
  }

  createChatRoom(String? chatRoomId, Map<String, dynamic> chatRoomIdMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection('chatroom')
          .doc(chatRoomId)
          .set(chatRoomIdMap);
    }
  }

  Future saveMessageToFireStore(
      String chatRoomID, String messageId, Map<String, dynamic> messageMap) {
    return FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatRoomID)
        .collection('chat')
        .doc(messageId)
        .set(messageMap);
  }

  Future saveRecentMessageToFireStore(
      String chatRoomID, Map<String, dynamic> recentMessageMap) {
    return FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatRoomID)
        .set(recentMessageMap);
  }

  Future<Stream<QuerySnapshot>> getChatMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chat')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserByUserName(String username) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where("Username", isEqualTo: username)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUserName = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection('chatroom')
        .orderBy('recentMessageTime', descending: true)
        .where('users', arrayContains: myUserName!.toUpperCase())
        .snapshots();
  }
}
