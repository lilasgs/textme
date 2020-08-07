import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:slim/slim.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms/contact.dart';
import 'package:sms/sms.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:textme/settings/assets.dart';

import 'chat.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SmsQuery query = new SmsQuery();
  SimCardsProvider provider = new SimCardsProvider();

  List<SmsThread> threads;
  bool loader = false;
  bool showFloatButton = true;

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus != PermissionStatus.granted) {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.request();

    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DENIED",
          message: "Access to location data denied",
          details: null);
    } else if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: "PERMISSION_DISABLED",
          message: "Location data is not available on device",
          details: null);
    }
  }

  @override
  void initState() {
    super.initState();
    _askPermissions();
    init();
  }

  Future init() async {
    threads = await query.getAllThreads;
    setState(() {
      loader = true;
    });

    UserProfileProvider provider = new UserProfileProvider();
    UserProfile profile = await provider.getUserProfile();
    print("User profile");
    print(profile.addresses);
    print(profile.thumbnail);
    print(profile.fullName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              _onStartScroll(scrollNotification.metrics);
            } else if (scrollNotification is ScrollEndNotification) {
              _onEndScroll(scrollNotification.metrics);
            }
          },
          child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: loader
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: threads.length,
                      itemBuilder: (BuildContext context, int index) {
                        return messageWidget(threads[index]);
                      },
                    )
                  : Center())),
      floatingActionButton: showFloatButton
          ? FloatingActionButton(
              onPressed: () {},
              child: Icon(FontAwesome.send),
            )
          : Center(),
    );
  }

  Widget messageWidget(SmsThread conversation) {
    double width = MediaQuery.of(context).size.width;
    //Contact c = refreshContacts(msg.address);
    return Container(
        child: ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationPage(thread: conversation)),
        );
      },
      title: Row(
        children: <Widget>[
          CircleAvatar(
            child: conversation.contact.photo != null
                ? CircleAvatar(
                    maxRadius: 25,
                    backgroundImage:
                        MemoryImage(conversation.contact.photo.bytes))
                : CircleAvatar(
                    child: Text(
                    conversation.contact.fullName != null
                        ? getInitials(conversation.contact.fullName)
                        : getInitials(conversation.contact.address),
                    style: TextStyle(fontSize: 20),
                  )),
            maxRadius: 25,
          ),
          Container(
              width: width - 100,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    conversation.contact.fullName != null
                        ? conversation.contact.fullName
                        : conversation.contact.address,
                    softWrap: true,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    conversation.messages.first.body,
                    softWrap: true,
                    style: TextStyle(
                        fontWeight: FontWeight.w400, color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ))
        ],
      ),
    ));
  }

  Future<void> refreshContacts(String numero) async {
    // Load without thumbnails initially.
    // var contacts = (await ContactsService.getContacts(
    //         withThumbnails: false, iOSLocalizedLabels: false))
    //     .toList();
    var contacts = (await ContactsService.getContactsForPhone(numero)).toList();

    print(contacts);
    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }

    return contacts;
  }

  _onStartScroll(ScrollMetrics metrics) {
    setState(() {
      showFloatButton = false;
    });
  }

  _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      showFloatButton = true;
    });
  }

  matchNumberWithcontact() {}
}
