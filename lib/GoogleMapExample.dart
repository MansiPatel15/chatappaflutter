import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapExample extends StatefulWidget {

  @override
  State<GoogleMapExample> createState() => _GoogleMapState();
}
class _GoogleMapState extends State<GoogleMapExample> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng _center =  LatLng(9.669111, 80.014007);

  GoogleMapController _controller;
  Location currentLocation = Location();
  Set<Marker> _markers={};

  Timer timer;
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  BitmapDescriptor customIcon;
  void getLocation() async{
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
        'image/google.png')
        .then((d) {
      customIcon = d;
    });

    timer = Timer.periodic(Duration(seconds: 10), (Timer t) async{
      await FirebaseFirestore.instance.collection("Employee").doc("QbDjaEFwFlSmXN2u3LL5").get().then((document){
        setState(() {
          _markers.add(Marker(markerId: MarkerId('Home'),icon: customIcon,
              position: LatLng(double.parse(document["lattitude"].toString()),double.parse(document["longtitude"].toString()))
          ));
        });
      });
    });
    // var location = await currentLocation.getLocation();
    // currentLocation.onLocationChanged.listen((LocationData loc){
    //
    //   _controller?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
    //     target: LatLng(loc.latitude ?? 0.0,loc.longitude?? 0.0),
    //     zoom: 12.0,
    //   )));
    //   print(loc.latitude);
    //   print(loc.longitude);
    //   setState(() {
    //     _markers.add(Marker(markerId: MarkerId('Home'),
    //         position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)
    //     ));
    //   });
    // });
  }

  @override
  void initState(){
    super.initState();
    setState(() {
      getLocation();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GoogleMap...."),
      ),
      body: GoogleMap(
          zoomControlsEnabled: false,
        mapType: MapType.terrain,
        initialCameraPosition: CameraPosition(
          target: LatLng(20.5937,78.9629),
          zoom: 9,
        ),
        // markers: markers.values.toSet(),
        onMapCreated: (GoogleMapController controller)
        {
          _controller = controller;
          // final marker = Marker(
          //   markerId: MarkerId('Katargam'),
          //   position: LatLng(21.2266, 72.8312),
          //   infoWindow: InfoWindow(
          //     title: 'title',
          //     snippet: 'address',
          //   ),
          // );
          // setState(() {
          //   markers[MarkerId('Katargam')] = marker;
          // });
          // final marker1 = Marker(
          //   markerId: MarkerId('Rander'),
          //  // icon: BitmapDescriptor.fromBytes(markerIcon),
          //   position: LatLng(21.2189, 72.7961),
          //   infoWindow: InfoWindow(
          //     title: 'title',
          //     snippet: 'address',
          //   ),
          // );
          // setState(() {
          //   markers[MarkerId('Rander')] = marker1;
          // });
          // final marker2 = Marker(
          //   markerId: MarkerId('Vesu'),
          //   position: LatLng(21.1418, 72.7709),
          //   infoWindow: InfoWindow(
          //     title: 'title',
          //     snippet: 'address',
          //   ),
          // );
          // setState(() {
          //   markers[MarkerId('Vesu')] = marker2;
          // });
        },
        markers : _markers,
      ),
    );
  }
}
