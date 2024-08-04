import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiil_up_app/order/checkout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewOrderScreen extends StatefulWidget {
  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('New Order', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Available Fuel Quantities',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text("The fuel quantity will update only after 24 hours", style: TextStyle(fontSize: 12, color: Colors.black)),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('fuelInventory').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No fuel inventory available'));
                }

                final inventory = snapshot.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    itemCount: inventory.length,
                    itemBuilder: (context, index) {
                      final item = inventory[index];
                      final data = item.data() as Map<String, dynamic>;
                      final quantity = data['quantity'] ?? 'N/A';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.white,
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            '${item.id}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow[700],
                            ),
                          ),
                          subtitle: Text(
                            'Available Quantity: ${quantity}L',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceOrder(),
                    ),
                  );
                },
                child: Text('Next', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 70, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
