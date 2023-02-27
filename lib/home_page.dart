import 'dart:async';
import 'dart:developer';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key,});
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController radiusController = TextEditingController();
  StreamSubscription<GeofenceStatus>? geofenceStatusStream;
  Geolocator geolocator = Geolocator();
  String geofenceStatus = '';
  bool isReady = false;
  Position? position;

  getCurrentPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    log("LOCATION => ${position!.toJson()}");
    isReady = (position != null) ? true : false;
  }

  setLocation() async {
    await getCurrentPosition();
    // print("POSITION => ${position!.toJson()}");
    latitudeController =
        TextEditingController(text: position!.latitude.toString());
    longitudeController =
        TextEditingController(text: position!.longitude.toString());
  }

   @override
  void dispose() {
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geo-Fencing Test"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (isReady) {
                setState(() {
                  setLocation();
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: latitudeController,
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Enter pointed latitude'),
            ),
            TextField(
              controller: longitudeController,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter pointed longitude'),
            ),
            TextField(
              controller: radiusController,
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Enter radius in meter'),
            ),
            const SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("Start"),
                  onPressed: () {
                    log("starting geoFencing Service");
                    EasyGeofencing.startGeofenceService(
                        pointedLatitude: latitudeController.text,
                        pointedLongitude: longitudeController.text,
                        radiusMeter: radiusController.text,
                        eventPeriodInSeconds: 5);
                    geofenceStatusStream ??= EasyGeofencing.getGeofenceStream()!
                          .listen((GeofenceStatus status) {
                        log(status.toString());
                        setState(() {
                          geofenceStatus = status.toString();
                        });
                      });
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  child: const Text("Stop"),
                  onPressed: () {
                    log("stop");
                    EasyGeofencing.stopGeofenceService();
                    geofenceStatusStream!.cancel();
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 100,
            ),
            Text(
              "Geofence Status: \n\n\n$geofenceStatus",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
