import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _pickedLocation = LatLng(41.9981, 21.4254);

  void _handleTap(LatLng latlng) {
    setState(() {
      _pickedLocation = latlng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избери Локација'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _pickedLocation,
          zoom: 13.0,
          onTap: (_, latlng) => _handleTap(latlng),
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: _pickedLocation,
                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Navigator.of(context)
              .pop(LatLng(_pickedLocation.latitude, _pickedLocation.longitude));
        },
      ),
    );
  }
}
