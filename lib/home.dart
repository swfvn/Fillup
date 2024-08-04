import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fiil_up_app/order/orderr.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> selectedOrders = [];
  double? lat;
  double? long;
  String locationMessage = 'Loading location...';
  LatLng initialCenter = LatLng(11.258753, 75.780411); // Default location

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((value) {
      setState(() {
        lat = value.latitude;
        long = value.longitude;
        locationMessage = 'Latitude: $lat, Longitude: $long';
        initialCenter = LatLng(lat!, long!); // Update initial center
      });
    });
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions.");
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FILLUP',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 250,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: 14,
                      interactionOptions: const InteractionOptions(
                          flags: ~InteractiveFlag.doubleTapZoom),
                    ),
                    children: [
                      openStreetMapTileLaywer,
                    ],
                  )),
              SizedBox(height: 20),
              Text(
                'Welcome to Fillup',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NewOrderScreen()), // Navigate to NewOrderScreen
                  );
                },
                child: Text('Place an order'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Current Fuel Prices',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('fuelPrices').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final prices = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: prices.length,
                    itemBuilder: (context, index) {
                      final price = prices[index];
                      final data = price.data() as Map<String, dynamic>;
                      final priceValue =
                          data.containsKey('price') ? data['price'] : 0.0;

                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.white,
                        child: ListTile(
                          leading: Icon(
                            Icons.local_gas_station_rounded,
                            color: Colors.yellow[700],
                            size: 36.0, // Adjust the size as needed
                          ),
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            '${price.id}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow[700],
                            ),
                          ),
                          subtitle: Text(
                            'Price: ₹${priceValue.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: _deleteSelectedOrders,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('orders').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final orders = snapshot.data!.docs.reversed.toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.0),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final data = order.data() as Map<String, dynamic>;
                        final price =
                            data.containsKey('amount') ? data['amount'] : 0.0;
                        final status = data.containsKey('status')
                            ? data['status']
                            : 'Unknown';

                        return _buildOrderCard(
                            order.id,
                            order,
                            '${data['fuelType']} - ${data['quantity']}L',
                            '₹${price.toStringAsFixed(2)}',
                            status);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(String orderId, QueryDocumentSnapshot order,
      String orderDetails, String price, String status) {
    return SizedBox(
      height:80,
      child: Card(
        child: ListTile(
          leading: Checkbox(
            value: selectedOrders.contains(orderId),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedOrders.add(orderId);
                } else {
                  selectedOrders.remove(orderId);
                }
              });
            },
          ),
          title: Text(orderDetails),
          subtitle: Text(price),
          trailing: Text(status),
        ),
      ),
    );
  }

  void _deleteSelectedOrders() async {
    for (String orderId in selectedOrders) {
      await _firestore.collection('orders').doc(orderId).delete();
    }
    setState(() {
      selectedOrders.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('')),
    );
  }
}

TileLayer get openStreetMapTileLaywer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
