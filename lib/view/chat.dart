import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sms/contact.dart';
import 'dart:math';

import 'package:sms/sms.dart';
import 'package:textme/settings/assets.dart';

class ConversationPage extends StatefulWidget {
  final SmsThread thread;

  const ConversationPage({Key key, this.thread}) : super(key: key);
  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  String text;
  TextEditingController _controller;

  final List<String> avatars = ["", ""];

  List<SmsMessage> messages;
  UserProfile profile;
  final rand = Random();
  SmsQuery query = new SmsQuery();

  @override
  void initState() {
    super.initState();
    getUserInfo();
    messages = widget.thread.messages;
    _controller = TextEditingController();
  }

  Future getUserInfo() async {
    List<SmsMessage> messages = await query.querySms(
        threadId: widget.thread.id,
        address: widget.thread.address,
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft]);

    print("Lister tous les ${messages.length} messages ");
    messages.forEach((e) => print(e.sender));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Row(
            children: <Widget>[
              CircleAvatar(
                child: widget.thread.contact.photo != null
                    ? CircleAvatar(
                        maxRadius: 15,
                        backgroundImage:
                            MemoryImage(widget.thread.contact.photo.bytes))
                    : CircleAvatar(
                        child: Text(
                        widget.thread.contact.fullName != null
                            ? getInitials(widget.thread.contact.fullName)
                            : getInitials(widget.thread.contact.address),
                        style: TextStyle(fontSize: 20),
                      )),
                maxRadius: 15,
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                widget.thread.contact.fullName != null
                    ? widget.thread.contact.fullName
                    : widget.thread.contact.address,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    color: Colors.white),
              )
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10.0);
                  },
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    // print("=========>");
                    // print(messages[index].address);
                    // print(messages[index].sender);
                    // print("=========>");

                    if (messages[index].sender == "08175631")
                      return _buildMessageRow(messages[index], current: true);
                    return _buildMessageRow(messages[index], current: false);
                  },
                ),
              ),
              _buildBottomBar(context),
            ],
          ),
        ));
  }

  Container _buildBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30.0),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 20.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.send,
              controller: _controller,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  hintText: "Aa"),
              onEditingComplete: _save,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _save,
          )
        ],
      ),
    );
  }

  _save() async {
    if (_controller.text.isEmpty) return;
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      //messages.insert(0, SmsMessage(rand.nextInt(2), _controller.text));
      _controller.clear();
    });
  }

  Row _buildMessageRow(SmsMessage message, {bool current}) {
    double width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment:
          current ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: current ? 30.0 : 20.0),
        if (!current) ...[
          CircleAvatar(
            child: widget.thread.contact.photo != null
                ? CircleAvatar(
                    maxRadius: 20,
                    backgroundImage:
                        MemoryImage(widget.thread.contact.photo.bytes))
                : CircleAvatar(
                    child: Text(
                    widget.thread.contact.fullName != null
                        ? getInitials(widget.thread.contact.fullName)
                        : getInitials(widget.thread.contact.address),
                    style: TextStyle(fontSize: 20),
                  )),
            maxRadius: 20,
          ),
          const SizedBox(width: 5.0),
        ],
        GestureDetector(
            onLongPress: () {},
            child: Container(
              width: width - 100,
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                  color:
                      current ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                message.body,
                style: TextStyle(
                    color: current ? Colors.white : Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w300),
              ),
            )),
        if (current) ...[
          const SizedBox(width: 5.0),
          CircleAvatar(
            child: widget.thread.contact.photo != null
                ? CircleAvatar(
                    maxRadius: 15,
                    backgroundImage:
                        MemoryImage(widget.thread.contact.photo.bytes))
                : CircleAvatar(
                    child: Text(
                    widget.thread.contact.fullName != null
                        ? getInitials(widget.thread.contact.fullName)
                        : "",
                    style: TextStyle(fontSize: 20),
                  )),
            maxRadius: 15,
          ),
        ],
        SizedBox(width: current ? 20.0 : 30.0),
      ],
    );
  }
}

class Message {
  final int user;
  final String description;

  Message(this.user, this.description);
}
