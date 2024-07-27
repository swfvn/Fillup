import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCustomerOrders extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Customer Orders'),
        backgroundColor: Colors.yellow, // AppBar color
      ),
      backgroundColor: Colors.white, // Background color
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0), // Padding for ListView
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0), // Card margin
                color: Colors.yellow[50], // Card background color
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0), // Padding inside ListTile
                  title: Text(
                    'Order #${order.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow, // Title text color
                    ),
                  ),
                  subtitle: Text(
                    'Fuel Type: ${order['fuelType']}\n'
                        'Quantity: ${order['quantity']}\n'
                        'Address: ${order['deliveryAddress']}\n'
                        'Status: ${order['status']}',
                    style: TextStyle(color: Colors.black87), // Subtitle text color
                  ),
                  onTap: () {
                    // Optionally navigate to order details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
