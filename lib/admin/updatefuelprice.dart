import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateFuelPrices extends StatefulWidget {
  @override
  _UpdateFuelPricesState createState() => _UpdateFuelPricesState();
}

class _UpdateFuelPricesState extends State<UpdateFuelPrices> {
  final _fuelTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  Future<void> _updatePrice() async {
    final fuelType = _fuelTypeController.text;
    final price = double.tryParse(_priceController.text);

    if (fuelType.isNotEmpty && price != null) {
      await _firestore.collection('fuelPrices').doc(fuelType).set({
        'price': price,
      });
      // Notify admin of successful update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Price updated successfully!')),
      );
      _fuelTypeController.clear();
      _priceController.clear();
    } else {
      // Handle validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid fuel type and price.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Fuel Prices'),
        backgroundColor: Colors.yellow,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _fuelTypeController,
              decoration: InputDecoration(
                labelText: 'Fuel Type',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
              ),
              cursorColor: Colors.yellow,
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
              ),
              cursorColor: Colors.yellow,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePrice,
              child: Text('Update Price'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
