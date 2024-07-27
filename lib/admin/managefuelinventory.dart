import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageFuelInventory extends StatefulWidget {
  @override
  _ManageFuelInventoryScreenState createState() => _ManageFuelInventoryScreenState();
}

class _ManageFuelInventoryScreenState extends State<ManageFuelInventory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _fuelTypeController = TextEditingController();
  final _quantityController = TextEditingController();

  Future<void> _updateFuelQuantity() async {
    final fuelType = _fuelTypeController.text;
    final quantity = int.tryParse(_quantityController.text);

    if (fuelType.isNotEmpty && quantity != null) {
      await _firestore.collection('fuelInventory').doc(fuelType).set({
        'quantity': quantity,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fuel quantity updated successfully!')),
      );
      _fuelTypeController.clear();
      _quantityController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid fuel type and quantity.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Manage Fuel Inventory', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Fuel Type',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: _fuelTypeController,
              decoration: InputDecoration(hintText: 'Enter fuel type'),
            ),
            SizedBox(height: 20),
            Text(
              'Quantity',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter quantity'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updateFuelQuantity,
                child: Text('Update', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
