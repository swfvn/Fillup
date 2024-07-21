import 'package:fiil_up_app/authentication/login.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_gas_station, size: 100, color: Colors.black),
            SizedBox(height: 20),
            Text(
              'Fast & Reliable.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Get fuel whenever you need, we are there'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
              },
              child: Text('Get Started'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.yellow, backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
