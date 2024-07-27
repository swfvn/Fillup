import 'package:fiil_up_app/admin/customerorders.dart';
import 'package:fiil_up_app/admin/managefuelinventory.dart';
import 'package:fiil_up_app/admin/updatefuelprice.dart';
import 'package:fiil_up_app/splash.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.yellow,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            tileColor: Colors.yellow,
            title: Text(
              'View Customer Orders',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.list, color: Colors.black),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCustomerOrders(), // Updated screen
                ),
              );
            },
          ),
          SizedBox(height: 10), // Space between tiles
          ListTile(
            tileColor: Colors.yellow,
            title: Text(
              'Manage Fuel Inventory',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.inventory, color: Colors.black),
            onTap: () {
              // Navigate to Inventory Management
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageFuelInventory(), // Replace with actual screen
                ),
              );
            },
          ),
          SizedBox(height: 10),
          ListTile(
            tileColor: Colors.yellow,
            title: Text(
              'Update Fuel Prices',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.price_change, color: Colors.black),
            onTap: () {
              // Navigate to Update Fuel Prices
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateFuelPrices(), // Replace with actual screen
                ),
              );
            },
          ),
          SizedBox(height: 55),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SplashScreen(),
                ),
              );
            },
            child: Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.red, backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
              shape: LinearBorder.top(),
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
