import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ImageView extends StatefulWidget {

  var img = "";

  ImageView({this.img});

  @override
  State<ImageView> createState() => _ImageViewState();
}


class _ImageViewState extends State<ImageView> {


  @override
  void initState() {
    // TODO: implement initState
  }

  var isloading=false;
  _save(url) async {
    setState(() {
      isloading=true;
    });
    var stutas = await Permission.storage.request();
    if (stutas.isGranted) {
      var response = await Dio().get(
          url,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "hello");
      print(result);
      setState(() {
        isloading=false;
      });

      //
      //
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(

            color: Colors.black12,
            height: MediaQuery.of(context).size.height,

            child: Column(
              children: [

                Image.network(widget.img),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: ()async{
                            final imageurl = widget.img;
                            final uri = Uri.parse(imageurl);
                            final response = await http.get(uri);
                            final bytes = response.bodyBytes;
                            final temp = await getTemporaryDirectory();
                            final path = '${temp.path}/image.jpg';
                            File(path).writeAsBytesSync(bytes);
                            await Share .shareFiles([path], text: 'Image Shared');

                          },

                          child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text("Share"),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: (isloading)?CircularProgressIndicator():ElevatedButton(
                        onPressed: ()async{

                          _save(widget.img);
                        },
                        child: Text("Dowanlod"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
