import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

User loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageClearer = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String messageText;

  @override
  void initState() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
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
          TextButton(
              child: Text(
                'LogOut',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder(
                stream: _firestore
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  Timer(const Duration(seconds: 5), (){ 
                      setState(() {
                      print(snapshot.data);
                          });});
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Flexible(
                    child: ListView(
                      reverse: true,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: snapshot.data.docs.map((doc) {
                        final currentUser = loggedInUser.email;
                        final sender = doc['sender'];
                        final bool isMe = currentUser == sender;
                        print(isMe);
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                (doc['sender']),
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 12),
                              ),
                              Material(
                                borderRadius: isMe
                                    ? BorderRadius.only(
                                        bottomLeft: Radius.circular(30.0),
                                        topLeft: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0),
                                      )
                                    : BorderRadius.only(
                                        bottomLeft: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0),
                                        topRight: Radius.circular(30.0),
                                      ),
                                color: isMe
                                    ? Colors.lightBlueAccent
                                    : Colors.white,
                                elevation: 5,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        doc['text'],
                                        style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black54),
                                      ),
                                    ),
                                    Text(
                                      doc['createdAt'].toDate().toString(),
                                      style: TextStyle(fontSize: 10.0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                        minLines: 1,
                        maxLines: 5,
                        controller: messageClearer,
                        onChanged: (value) {
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        messagesStream();
                        await _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        messageClearer.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: CircleAvatar(
                        radius: 24.0,
                        backgroundColor: Colors.lightBlue,
                        child: Center(
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
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
