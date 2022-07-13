import 'package:chatapp/ChatScreen.dart';
import 'package:chatapp/LoginScreen.dart';
import 'package:chatapp/SplashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var name = "", email = "", photo = "", googleid = "";

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name");
      email = prefs.getString("email");
      photo = prefs.getString("photo");
      googleid = prefs.getString("googleid");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove("islogin");

              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.signOut();

              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SplashScreen()));
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: EdgeInsets.all(10),
      //     child: Column(
      //       children: [
      //         ListTile(
      //           contentPadding: EdgeInsets.all(0),
      //           leading: CircleAvatar(
      //               radius: (30),
      //               backgroundColor: Colors.blue,
      //               child: ClipRRect(
      //                 borderRadius: BorderRadius.circular(50),
      //                 child: Text(photo),
      //               )),
      //           title: Text(name,
      //             style: TextStyle(fontSize: 15),
      //           ),
      //           subtitle: Text(email),
      //           onTap: () {
      //             Navigator.of(context).pop();
      //             Navigator.of(context).push(
      //                 MaterialPageRoute(builder: (context) => ChatScreen()));
      //           },
      //         )
      //       ],
      //     ),
      //   ),
      // ),
      // body: Container(
      //   color: Color(0xFFbbdefb),
      //   width: MediaQuery.of(context).size.width,
      //   height: 300,
      //   child: Padding(
      //     padding: EdgeInsets.all(10.0),
      //     child:Column(
      //       children: [
      //         Text("Name : "+name,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
      //         Divider(
      //           color: Colors.black,
      //           height: 20,
      //           thickness: 3,
      //         ),
      //         Text("Email : "+email,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
      //         Divider(
      //           color: Colors.black,
      //           thickness: 3,
      //           height: 20,
      //         ),
      //         Text("Photo : "+photo,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
      //         Divider(
      //           color: Colors.black,
      //           height: 20,
      //           thickness: 3,
      //         ),
      //         Text("GoogleId : "+googleid,style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,),),
      //         Divider(
      //           color: Colors.black,
      //           height: 20,
      //           thickness: 3,
      //         ),
      //         SizedBox(
      //           height: 20,
      //         ),
      //         ElevatedButton(
      //             onPressed: () async{
      //               SharedPreferences prefs = await SharedPreferences.getInstance();
      //               prefs.remove("islogin");
      //
      //               GoogleSignIn googleSignIn = GoogleSignIn();
      //               googleSignIn.signOut();
      //
      //               Navigator.of(context).pop();
      //               Navigator.of(context).push(
      //                   MaterialPageRoute(builder: (context)=> ChatScreen())
      //               );
      //             },
      //             child: Text("LogOut",style: TextStyle(fontSize: 20),)
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").where("email",isNotEqualTo: email).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.size <= 0) {
              return Center(
                child: Text("No data"),
              );
            } else {
              return ListView(
                children: snapshot.data.docs.map((document) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(document["photo"]),
                    ),
                    title: Text(document["name"],style: TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text(
                      document["email"],
                    ),
                    onTap: () {
                      var docid = document.id.toString();

                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatScreen(receiverid:docid,name:document["name"].toString(),email: document["email"].toString(),photo: document["photo"].toString(),)));
                    },
                  );
                }).toList(),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
