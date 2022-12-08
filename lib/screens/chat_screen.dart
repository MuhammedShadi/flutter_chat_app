// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

final _fireStore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? messageText;
  Timestamp? messageTime;
  final messageController = TextEditingController();

  void getUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      print(user.email);
      print(user.displayName);
    }
  }

  void getMessages() async {
    final messages = await _fireStore.collection("messages").get();
    for (var message in messages.docs) {
      print(message.data());
    }
  }

  void messageStream() async {
    await for (var snapshot in _fireStore.collection("messages").snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              padding: EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTime = Timestamp.now();
                      _fireStore.collection("messages").add({
                        "text": messageText,
                        "sender": _auth.currentUser!.email,
                        "time": messageTime,
                      });
                      messageController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _fireStore.collection("messages").orderBy('time', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.amberAccent,
              value: 10,
            ),
          );
        } else {
          final messages = snapshot.data!.docs;
          List<MessageBubble> messagesBubbles = [];
          for (var message in messages) {
            final messageText = message.data()["text"];
            final messageSender = message.data()["sender"];
            final Timestamp?  messageTime = message.data()["time"];
            final currentUser = _auth.currentUser!.email;

            if (currentUser == messageSender) {}
            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender,
              time: messageTime,
            );
            messagesBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              children: messagesBubbles,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {Key? key, required this.sender, required this.text, required this.isMe,required this.time})
      : super(key: key);
  final String? sender;
  final String? text;
  final Timestamp? time;
  bool? isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            "$sender",
            style: TextStyle(color: Colors.black54, fontSize: 10.0),
          ),
          Material(
            borderRadius:isMe! ?  BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ): BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            elevation: 5,
            color: isMe! ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25),
              child: Text(
                '$text',
                style: TextStyle(color: isMe! ? Colors.white:Colors.black54, fontSize: 15.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "${time?.toDate().day}-${time?.toDate().month}-${time?.toDate().year}  ${time?.toDate().hour}:${time?.toDate().minute}",
              style: TextStyle(color: Colors.black54, fontSize: 10.0),
            ),
          ),
        ],
      ),
    );
  }
}
