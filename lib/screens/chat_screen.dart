import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var massage in snapshot.docs) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
//            StreamBuilder<QuerySnapshot>(
//              stream: _firestore.collection('messages').snapshots(),
//              builder: (context, snapshot) {
//                if (!snapshot.hasData) {
//                  return Center(
//                    child: CircularProgressIndicator(),
//                  );
//                }
//                final messages = snapshot.data.docs;
//                List<Text> messageWidgets = [];
//                for (var message in messages) {
//                  final messageText = message.data('sender');
//                  final messageSender = message.data('text');
//                  final messageWidget =
//                      Text('$messageText from $messageSender');
//                  messageWidgets.add(messageWidget);
//                }
//                return Column(
//                  children: [messageWidgets],
//                );
//              },
//            ),
            StreamBuilder(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                if (!snapshot.hasData) {
//                  return Center(
//                    child: CircularProgressIndicator(),
//                  );
//                }
                return Expanded(
                  child: ListView(
//                        shrinkWrap: true,
                    children: snapshot.data.docs.map((doc) {
                      return Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 6,
                        child: Text(
                          "text" + doc['text'],
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messagesStream();
                      _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                      });
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
