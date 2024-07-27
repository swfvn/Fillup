import 'package:fiil_up_app/order/checkout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fiil_up_app/order/orderr.dart'; // Ensure this is the correct path for your NewOrderScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late GoogleMapController _controller;

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.258753, 75.780411), // Coordinates for Calicut
    zoom: 14.0, // Adjust zoom level as needed
  );

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('fuel_station_1'),
      position: LatLng(11.259, 75.781), // Example coordinates
      infoWindow: InfoWindow(title: 'Fuel Station 1'),
    ),
    Marker(
      markerId: MarkerId('landmark_1'),
      position: LatLng(11.260, 75.782), // Example coordinates
      infoWindow: InfoWindow(title: 'Landmark 1'),
    ),
  };

  final String _mapStyle = '''[
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    }
  ]''';

  List<String> selectedOrders = [];

  @override
  void initState() {
    super.initState();
    // Initialize map style
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FILLUP',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: Colors.black),
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
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    _controller.setMapStyle(_mapStyle);
                  },
                ),
              ),
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
                    MaterialPageRoute(builder: (context) => NewOrderScreen()), // Navigate to NewOrderScreen
                  );
                },
                child: Text('Place an order'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildFuelTypeCard('Petrol')),
                  SizedBox(width: 10),
                  Expanded(child: _buildFuelTypeCard('Diesel')),
                ],
              ),
              SizedBox(height: 20),
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
                    padding: EdgeInsets.all(16.0),
                    itemCount: prices.length,
                    itemBuilder: (context, index) {
                      final price = prices[index];
                      final data = price.data() as Map<String, dynamic>;
                      final priceValue = data.containsKey('price') ? data['price'] : 0.0;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.yellow[50],
                        child: ListTile(
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
                          onTap: () {
                            // Navigate to PlaceOrder screen with the selected price
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaceOrder(fuelPrice: priceValue),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20),
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
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('orders').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.0),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final data = order.data() as Map<String, dynamic>;
                      final price = data.containsKey('amount') ? data['amount'] : 0.0;
                      final status = data.containsKey('status') ? data['status'] : 'Unknown';

                      return _buildOrderCard(order.id, order, '${data['fuelType']} - ${data['quantity']}L', '₹${price.toStringAsFixed(2)}', status);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String orderId, QueryDocumentSnapshot order, String orderDetails, String price, String status) {
    return Card(
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

  Widget _buildFuelTypeCard(String fuelType) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.local_gas_station, size: 40, color: Colors.yellow),
            SizedBox(height: 10),
            Text(fuelType, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
