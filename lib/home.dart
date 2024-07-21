import 'package:fiil_up_app/order/orderr.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HomeScreen extends StatelessWidget {
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.258753, 75.780411),
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fillup',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 32),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (GoogleMapController controller) {
                  _initialPosition.toMap();
                  Matrix4.zero();
                  ZoomPageTransitionsBuilder();
                  // Perform any additional map setup here if needed
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Fillup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NewOrderScreen(),));
              },
              child: Text('Place an order'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.yellow,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Fuel Rates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FuelRateCard(fuelType: 'Petrol', rate: '96.72'),
                FuelRateCard(fuelType: 'Diesel', rate: '89.62'),


              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    List<List>;

                  },
                  child: Text('See more'),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  OrderCard(orderDetails: '10 litre Petrol', price: '670.00', status: 'Delivered'),
                  // Add more OrderCard widgets here
                ],
              ),
            ),
          ],
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
}

class FuelRateCard extends StatelessWidget {
  final String fuelType;
  final String rate;

  const FuelRateCard({
    required this.fuelType,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Text(
              fuelType,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('\u{20B9}$rate'), // \u{20B9} is the Unicode for the Indian Rupee symbol
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderDetails;
  final String price;
  final String status;

  const OrderCard({
    required this.orderDetails,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.local_gas_station),
        title: Text(orderDetails),
        subtitle: Text('\u{20B9}$price'),
        trailing: Text(status),
      ),
    );
  }
}
