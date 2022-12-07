// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

final _fireStore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String? messageText;
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
                      _fireStore.collection("messages").add({
                        "test": messageText,
                        "sender": _auth.currentUser!.email,
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
      stream: _fireStore.collection("messages").snapshots(),
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
            final messageText = message.data()["test"];
            final messageSender = message.data()["sender"];
            final messageBubble =
                MessageBubble(text: messageText, sender: messageSender);
            messagesBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
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
  const MessageBubble({Key? key, required this.sender, required this.text})
      : super(key: key);
  final String? sender;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "$sender",
            style: TextStyle(color: Colors.black54, fontSize: 10.0),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            elevation: 5,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
