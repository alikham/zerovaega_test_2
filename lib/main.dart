import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_marker_test/widgets/my_drawer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

List<String> bikeOptions = ['All bikes', 'Next-gen ebikes', 'Ebikes'];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Map Marker',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? controller;
  LatLng center = const LatLng(19.0759837, 72.8776559);

  CameraPosition _kGoogle =
      const CameraPosition(target: LatLng(19.0759837, 72.8776559), zoom: 12);

  String _mapStyle = '';
  String _mapStyleIos = '';

  Uint8List? marketimages;

  String dropdownvalue = bikeOptions.first;

  final List<Marker> _markers = <Marker>[];

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
    Map<Permission, PermissionStatus> status = await [
      Permission.location,
    ].request();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    rootBundle.loadString('assets/map_style.json').then((string) {
      _mapStyleIos = string;
    });
    if (status.values.contains(PermissionStatus.granted)) {
      Position currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _kGoogle = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 12);
    }

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
        key: scaffoldKey,
        drawer: const MyDrawer(),
        body: Column(
          children: [
            Expanded(
              child: Stack(
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
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          RawMaterialButton(
                            onPressed: () =>
                                scaffoldKey.currentState?.openDrawer(),
                            child: const Card(
                              color: Colors.white,
                              elevation: 6,
                              // padding: const EdgeInsets.all(8),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.menu),
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            onPressed: () {},
                            child: const Card(
                              color: Colors.white,
                              elevation: 6,
                              // padding: const EdgeInsets.all(8),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.help),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 0,
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
            Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Row(
                      children: [
                        DropdownButton(
                          underline: Container(),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                          ),
                          value: dropdownvalue,
                          items: bikeOptions
                              .map((e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    e,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              dropdownvalue = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () {},
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.qr_code_scanner_sharp,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Scan',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black26,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.pedal_bike,
                  size: 28,
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.train,
                  size: 28,
                ),
                label: '',
              ),
            ]),
      ),
    );
  }
}
