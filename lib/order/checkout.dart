import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceOrder extends StatefulWidget {
  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _mobileController = TextEditingController();

  String _selectedFuelType = 'petrol';
  String _selectedPaymentMethod = 'GPay';
  double _totalAmount = 0.0;
  double _currentFuelPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchFuelPrices();
  }

  void _fetchFuelPrices() async {
    if (_selectedFuelType == null) {
      return;
    }

    try {
      QuerySnapshot snapshot = await _firestore.collection('fuelPrices').get();
      List<DocumentSnapshot> prices = snapshot.docs;
      for (var price in prices) {
        if (price.id == _selectedFuelType) {
          var data = price.data() as Map<String, dynamic>; // Cast to Map
          var priceValue = data['price'];
          if (priceValue is double) {
            _currentFuelPrice = priceValue;
          } else if (priceValue is int) {
            _currentFuelPrice = priceValue.toDouble();
          } else {
            print('Error: Price data is not a double or int');
          }
          setState(() {
            _calculateTotalAmount();
          });
          break;
        }
      }
    } catch (e) {
      print('Error fetching fuel prices: $e');
    }
  }


  void _calculateTotalAmount() {
    print('Current Fuel Price: $_currentFuelPrice');
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;
    print('Fetching fuel quantity: $quantity');
    setState(() {
      _totalAmount = quantity * _currentFuelPrice;
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
        'status': 'Done',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!\n Your Delivery Will Arrive Within 30 Minutes')),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                decoration: InputDecoration(
                  labelText: 'Fuel Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_gas_station, color: Colors.yellow[700]),
                  fillColor: Colors.white,
                  filled: true,
                ),
                items: <String>['petrol', 'Deisel'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFuelType = newValue!;
                    _currentFuelPrice = 0.0;
                    _fetchFuelPrices();
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity (in liters)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.production_quantity_limits, color: Colors.yellow[700]),
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
                onChanged: (value) {
                  _calculateTotalAmount();
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Delivery Location (with Pincode)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on, color: Colors.yellow[700]),
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the delivery location address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone, color: Colors.yellow[700],),
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mobile number';
                  }
                  return null;
                },
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
                onPressed: _quantityController.text.isEmpty || _locationController.text.isEmpty || _mobileController.text.isEmpty || _selectedPaymentMethod.isEmpty
                    ? null
                    : _submitOrder,
                child: Text('Place Order'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
