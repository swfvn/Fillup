import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceOrder extends StatefulWidget {
  final double fuelPrice;

  PlaceOrder({required this.fuelPrice});

  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _mobileController = TextEditingController();

  String _selectedFuelType = 'Petrol';
  String _selectedPaymentMethod = 'GPay';
  double _totalAmount = 0.0;

  final _firestore = FirebaseFirestore.instance;

  void _calculateAmount() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _totalAmount = quantity * widget.fuelPrice;
    });
  }

  void _submitOrder() async {
    final quantity = _quantityController.text;
    final location = _locationController.text;
    final mobile = _mobileController.text;

    if (quantity.isEmpty || location.isEmpty || mobile.isEmpty || _selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields!')),
      );
      return;
    }

    try {
      await _firestore.collection('orders').add({
        'fuelType': _selectedFuelType,
        'quantity': quantity,
        'deliveryAddress': location,
        'mobile': mobile,
        'paymentMethod': _selectedPaymentMethod,
        'amount': _totalAmount,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!\n Your Delivery Will Arrive Within 30 Minutes'),),
      );

      _quantityController.clear();
      _locationController.clear();
      _mobileController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Place Fuel Order'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedFuelType,
              decoration: InputDecoration(
                labelText: 'Fuel Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station, color: Colors.yellow),
              ),
              items: <String>['Petrol', 'Diesel'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFuelType = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (in liters)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.exposure_plus_1, color: Colors.yellow),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _calculateAmount(); // Recalculate amount on quantity change
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Delivery Location (with Pincode)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on, color: Colors.yellow),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, color: Colors.yellow),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedPaymentMethod,
              items: <String>['GPay', 'PhonePe', 'Paytm', 'UPI'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            if (_quantityController.text.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Total Amount: ₹${_totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOrder,
              child: Text('Place Order'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
