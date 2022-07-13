import 'dart:io';
import 'package:chatapp/ImageView.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:chatapp/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  var receiverid, name, email, photo;

  ChatScreen({this.receiverid, this.name, this.email, this.photo});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ImagePicker _picker = ImagePicker();
  File file;
  var name = "", email = "", photo = "", googleid = "";
  var senderid = "";
  TextEditingController _msg = TextEditingController();

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      email = prefs.getString("email");
      photo = prefs.getString("photo");
      senderid = prefs.getString("senderid");
      googleid = prefs.getString("googleid");
    });
  }

  bool emojiShowing = false;
  _onEmojiSelected(Emoji emoji) {
    print("Selecteeeeeed");
    _msg
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _msg.text.length));
  }
  _onBackspacePressed() {
    _msg
      ..text = _msg.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _msg.text.length));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  final ScrollController _scrollcontroller = ScrollController();
  void _scrollDown() {
    _scrollcontroller.jumpTo(_scrollcontroller.position.minScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(63),
        child: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          titleSpacing: 0,
          title: ListTile(
            contentPadding: EdgeInsets.all(0),
            leading: CircleAvatar(
              radius: (20),
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(widget.photo),
            ),
            title: Text(
              widget.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white),
            ),
            subtitle: Text(
              widget.email,
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.call),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Group info"),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text("Group media"),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text("Search"),
                  value: 3,
                ),
                PopupMenuItem(
                  child: Text("Mute notifications"),
                  value: 4,
                ),
                PopupMenuItem(
                  child: Text("Wallpapaer"),
                  value: 5,
                ),
                PopupMenuItem(
                  child: Text("More"),
                  value: 6,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              // margin: new EdgeInsets.symmetric(horizontal: 20.0),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Users")
                      .doc(senderid)
                      .collection("Chats")
                      .doc(widget.receiverid)
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.size <= 0) {
                        return Center(child: Text("No Messages"));
                      } else {
                        return ListView(
                          controller: _scrollcontroller,
                          reverse: true,
                          children: snapshot.data.docs.map((document) {
                            if (document["senderid"] == senderid) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  padding: EdgeInsets.all(10.0),
                                  child: (document["messagetype"] == "image") ? GestureDetector(
                                    onTap: (){
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context)=>ImageView(img: document["msg"],))
                                      );
                                    },
                                  child:Image.network(
                                          document["msg"],
                                          width: 200,),
                                  )
                                      : Text(
                                          document["msg"],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                  decoration: BoxDecoration(
                                      color: Colors.purple.shade800,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                              ),
                              );
                            } else {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      color: Colors.purple.shade500,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: (document["messagetype"] == "image")
                                      ? Image.network(
                                          document["msg"],
                                          width: 200,
                                        )
                                      : Text(
                                          document["msg"],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              );
                            }
                          }).toList(),
                        );
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
          ),
          // Container(
          //   child: Container(
          //     width: MediaQuery.of(context).size.width,
          //     margin: EdgeInsets.only(left: 0,right: 50,bottom: 0),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(50),
          //   ),
          //   height: 50,
          //   child: TextField(
          //     controller: _msg,
          //     keyboardType: TextInputType.text,
          //     decoration: InputDecoration(
          //       border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(50)),
          //       isDense: true,
          //       prefixIcon: IconButton(
          //         onPressed: () {
          //           setState(() {
          //             emojiShowing = !emojiShowing;
          //           });
          //         },
          //         icon: Icon(
          //           Icons.emoji_emotions,
          //           size: 25,
          //           color: Colors.black45,
          //         ),
          //       ),
          //       hintText: "Message",
          //       suffixIcon: Container(
          //         width: 150,
          //         child: Row(
          //           children: [
          //             IconButton(
          //               onPressed: () {
          //               },
          //               icon: Icon(
          //                 Icons.attachment_outlined,
          //                 size: 25,
          //                 color: Colors.black45,
          //               ),
          //             ),
          //             IconButton(
          //               onPressed: () async {
          //                 XFile pickedimage = await _picker.pickImage(
          //                     source: ImageSource.gallery);
          //                 file = File(pickedimage.path);
          //
          //                 var uuid = Uuid();
          //                 var filename = uuid.v4().toString() + ".jpg";
          //
          //                 await FirebaseStorage.instance
          //                     .ref(filename)
          //                     .putFile(file)
          //                     .whenComplete(() {})
          //                     .then((filedata) async {
          //                   await filedata.ref
          //                       .getDownloadURL()
          //                       .then((fileurl) async {
          //                     var timestamp =
          //                         DateTime.now().millisecondsSinceEpoch;
          //
          //                     await FirebaseFirestore.instance
          //                         .collection("Users")
          //                         .doc(senderid)
          //                         .collection("Chats")
          //                         .doc(widget.receiverid)
          //                         .collection("messages")
          //                         .add({
          //                       "senderid": senderid,
          //                       "receiverid": widget.receiverid,
          //                       "msg": fileurl,
          //                       "timestamp": timestamp,
          //                       "messagetype": "image"
          //                     }).then((value) async {
          //                       await FirebaseFirestore.instance
          //                           .collection("Users")
          //                           .doc(widget.receiverid)
          //                           .collection("Chats")
          //                           .doc(senderid)
          //                           .collection("messages")
          //                           .add({
          //                         "senderid": senderid,
          //                         "receiverid": widget.receiverid,
          //                         "msg": fileurl,
          //                         "timestamp": timestamp,
          //                         "messagetype": "image"
          //                       }).then((value) {
          //                         _msg.text = "";
          //
          //                       });
          //                     });
          //                   });
          //                 });
          //               },
          //               icon: Icon(
          //                 Icons.image,
          //                 size: 25,
          //                 color: Colors.black45,
          //               ),
          //             ),
          //             IconButton(
          //               onPressed: () async {
          //                 // print('camera button pressed');
          //                 XFile pickedimage = await _picker.pickImage(
          //                     source: ImageSource.camera);
          //                 file = File(pickedimage.path);
          //
          //                 var uuid = Uuid();
          //                 var filename = uuid.v4().toString() + ".jpg";
          //
          //                 await FirebaseStorage.instance
          //                     .ref(filename)
          //                     .putFile(file)
          //                     .whenComplete(() {})
          //                     .then((filedata) async {
          //                   await filedata.ref
          //                       .getDownloadURL()
          //                       .then((fileurl) async {
          //                     var timestamp =
          //                         DateTime.now().millisecondsSinceEpoch;
          //
          //                     await FirebaseFirestore.instance
          //                         .collection("Users")
          //                         .doc(senderid)
          //                         .collection("Chats")
          //                         .doc(widget.receiverid)
          //                         .collection("messages")
          //                         .add({
          //                       "senderid": senderid,
          //                       "receiverid": widget.receiverid,
          //                       "msg": fileurl,
          //                       "timestamp": timestamp,
          //                       "messagetype": "image"
          //                     }).then((value) async {
          //                       await FirebaseFirestore.instance
          //                           .collection("Users")
          //                           .doc(widget.receiverid)
          //                           .collection("Chats")
          //                           .doc(senderid)
          //                           .collection("messages")
          //                           .add({
          //                         "senderid": senderid,
          //                         "receiverid": widget.receiverid,
          //                         "msg": fileurl,
          //                         "timestamp": timestamp,
          //                         "messagetype": "image"
          //                       }).then((value) {
          //                         _msg.text = "";
          //                       });
          //                     });
          //                   });
          //                 });
          //               },
          //               icon: Icon(
          //                 Icons.camera_alt,
          //                 size: 25,
          //                 color: Colors.black45,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // )
          // ),

          // Container(
          //   child:  Positioned(
          //     bottom: 10,
          //     right: 5,
          //     child:Container(
          //       decoration: BoxDecoration(
          //         color: Colors.blue[500],
          //         borderRadius: BorderRadius.all(Radius.circular(30)),
          //       ),
          //       width: 50,
          //       height: 50,
          //       child: IconButton(
          //         icon: Icon(
          //           Icons.send,
          //           size: 30,
          //           color: Colors.white,
          //         ),
          //         alignment: Alignment.center,
          //         onPressed: () async {
          //           // print("Receiver id : "+widget.receiverid.toString());
          //           // print("Sender id : "+senderid);
          //           var message = _msg.text.toString();
          //
          //           var timestamp = DateTime.now().millisecondsSinceEpoch;
          //           if (message.length >= 1) {
          //             await FirebaseFirestore.instance
          //                 .collection("Users")
          //                 .doc(senderid)
          //                 .collection("Chats")
          //                 .doc(widget.receiverid)
          //                 .collection("messages")
          //                 .add({
          //               "senderid": senderid,
          //               "receiverid": widget.receiverid,
          //               "msg": message,
          //               "timestamp": timestamp,
          //               "messagetype": "text"
          //             }).then((value) async {
          //               await FirebaseFirestore.instance
          //                   .collection("Users")
          //                   .doc(widget.receiverid)
          //                   .collection("Chats")
          //                   .doc(senderid)
          //                   .collection("messages")
          //                   .add({
          //                 "senderid": senderid,
          //                 "receiverid": widget.receiverid,
          //                 "msg": message,
          //                 "timestamp": timestamp,
          //                 "messagetype": "text"
          //               }).then((value) {
          //                 _msg.text = "";
          //                 _scrollDown();
          //               });
          //             });
          //           }
          //         },
          //       ),
          //     ),
          //   ),
          // ),

          // Container(
          //   child:
          // ),

          // Container(
          //   child: Stack(
          //     children: [
          //       Positioned(
          //         bottom: 10,
          //         right: 5,
          //         child:
          //       ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  margin: EdgeInsets.only(left: 0, right: 10, bottom: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  height: 50,
                  child: TextField(
                    controller: _msg,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                      isDense: true,
                      prefixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            emojiShowing = !emojiShowing;
                          });
                        },
                        icon: Icon(
                          Icons.emoji_emotions,
                          size: 25,
                          color: Colors.black45,
                        ),
                      ),
                      hintText: "Message",
                      suffixIcon: Container(
                        width: 150,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.attachment_outlined,
                                size: 25,
                                color: Colors.black45,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                XFile pickedimage = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                file = File(pickedimage.path);

                                var uuid = Uuid();
                                var filename = uuid.v4().toString() + ".jpg";

                                await FirebaseStorage.instance
                                    .ref(filename)
                                    .putFile(file)
                                    .whenComplete(() {})
                                    .then((filedata) async {
                                  await filedata.ref
                                      .getDownloadURL()
                                      .then((fileurl) async {
                                    var timestamp =
                                        DateTime.now().millisecondsSinceEpoch;

                                    await FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(senderid)
                                        .collection("Chats")
                                        .doc(widget.receiverid)
                                        .collection("messages")
                                        .add({
                                      "senderid": senderid,
                                      "receiverid": widget.receiverid,
                                      "msg": fileurl,
                                      "timestamp": timestamp,
                                      "messagetype": "image"
                                    }).then((value) async {
                                      await FirebaseFirestore.instance
                                          .collection("Users")
                                          .doc(widget.receiverid)
                                          .collection("Chats")
                                          .doc(senderid)
                                          .collection("messages")
                                          .add({
                                        "senderid": senderid,
                                        "receiverid": widget.receiverid,
                                        "msg": fileurl,
                                        "timestamp": timestamp,
                                        "messagetype": "image"
                                      }).then((value) {
                                        _msg.text = "";
                                      });
                                    });
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.image,
                                size: 25,
                                color: Colors.black45,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                // print('camera button pressed');
                                XFile pickedimage = await _picker.pickImage(
                                    source: ImageSource.camera);
                                file = File(pickedimage.path);

                                var uuid = Uuid();
                                var filename = uuid.v4().toString() + ".jpg";

                                await FirebaseStorage.instance
                                    .ref(filename)
                                    .putFile(file)
                                    .whenComplete(() {})
                                    .then((filedata) async {
                                  await filedata.ref
                                      .getDownloadURL()
                                      .then((fileurl) async {
                                    var timestamp =
                                        DateTime.now().millisecondsSinceEpoch;

                                    await FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(senderid)
                                        .collection("Chats")
                                        .doc(widget.receiverid)
                                        .collection("messages")
                                        .add({
                                      "senderid": senderid,
                                      "receiverid": widget.receiverid,
                                      "msg": fileurl,
                                      "timestamp": timestamp,
                                      "messagetype": "image"
                                    }).then((value) async {
                                      await FirebaseFirestore.instance
                                          .collection("Users")
                                          .doc(widget.receiverid)
                                          .collection("Chats")
                                          .doc(senderid)
                                          .collection("messages")
                                          .add({
                                        "senderid": senderid,
                                        "receiverid": widget.receiverid,
                                        "msg": fileurl,
                                        "timestamp": timestamp,
                                        "messagetype": "image"
                                      }).then((value) {
                                        _msg.text = "";
                                      });
                                    });
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.camera_alt,
                                size: 25,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
               Container(
                 margin: EdgeInsets.only(right: 4,bottom: 0),
                  decoration: BoxDecoration(
                    color: Colors.blue[500],
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  //width: 50,
                 // height: 50,
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 30,
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    onPressed: () async {
                      // print("Receiver id : "+widget.receiverid.toString());
                      // print("Sender id : "+senderid);
                      var message = _msg.text.toString();

                      var timestamp = DateTime.now().millisecondsSinceEpoch;
                      if (message.length >= 1) {
                        await FirebaseFirestore.instance
                            .collection("Users")
                            .doc(senderid)
                            .collection("Chats")
                            .doc(widget.receiverid)
                            .collection("messages")
                            .add({
                          "senderid": senderid,
                          "receiverid": widget.receiverid,
                          "msg": message,
                          "timestamp": timestamp,
                          "messagetype": "text"
                        }).then((value) async {
                          await FirebaseFirestore.instance
                              .collection("Users")
                              .doc(widget.receiverid)
                              .collection("Chats")
                              .doc(senderid)
                              .collection("messages")
                              .add({
                            "senderid": senderid,
                            "receiverid": widget.receiverid,
                            "msg": message,
                            "timestamp": timestamp,
                            "messagetype": "text"
                          }).then((value) {
                            _msg.text = "";
                            _scrollDown();
                          });
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
          SizedBox(height: 10,),
          Offstage(
            offstage: !emojiShowing,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                  onEmojiSelected: (Category category, Emoji emoji) {
                    _onEmojiSelected(emoji);
                  },
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                      columns: 7,
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      initCategory: Category.RECENT,
                      bgColor: const Color(0xFFF2F2F2),
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      progressIndicatorColor: Colors.blue,
                      backspaceColor: Colors.blue,
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      showRecentsTab: true,
                      recentsLimit: 28,
                      noRecentsText: 'No Recents',
                      noRecentsStyle:
                          const TextStyle(fontSize: 20, color: Colors.black26),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL)),
            ),
          ),
        ],
      ),
    );
  }
}
