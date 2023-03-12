import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GFG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // First screen of our app
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GoogleMapController? controller;
  static const LatLng center = LatLng(19.0759837, 72.8776559);

  static const CameraPosition _kGoogle = CameraPosition(
    target: center,
    zoom: 12.0,
  );

  String _mapStyle = '';
  String _mapStyleIos = '';

  Uint8List? marketimages;

// created empty list of markers
  final List<Marker> _markers = <Marker>[];

// declared method to get Images
  Future<Uint8List> getImages(int width) async {
    ByteData data = await rootBundle.load('assets/scooter_vector.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  moveToCurrentLocation() async {
    Position currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('here ${currentLocation.latitude} ${currentLocation.longitude}');
    controller?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(currentLocation.latitude, currentLocation.longitude), 14));
  }

  @override
  void initState() {
    super.initState();

    loadData();
  }

// created method for displaying custom markers according to index
  loadData() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleIos = string;
    });

    for (int i = 0; i < 6; i++) {
      final Uint8List markIcons = await getImages(100);

      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(i.toString()),
          icon: BitmapDescriptor.fromBytes(markIcons),
          position: LatLng(
            center.latitude + sin(i * pi / 6.0) / 20.0,
            center.longitude + cos(i * pi / 6.0) / 20.0,
          ),
          infoWindow: InfoWindow(
              title: 'Location: ${i + 1}', snippet: '${i + 1 * 10} min away'),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kGoogle,
              markers: Set<Marker>.of(_markers),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              indoorViewEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController gcontroller) {
                controller = gcontroller;

                if (Platform.isAndroid) {
                  controller?.setMapStyle(_mapStyle);
                }
                if (Platform.isIOS) {
                  controller?.setMapStyle(_mapStyleIos);
                }
              },
            ),
            Positioned(
              top: 8,
              right: -8,
              child: RawMaterialButton(
                onPressed: moveToCurrentLocation,
                child: const Card(
                  color: Colors.white,
                  elevation: 6,
                  // padding: const EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.my_location),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
