import 'package:fiil_up_app/authentication/signup.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 40.0,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with the actual image URL
                ),
                SizedBox(height: 10.0),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.0),
                Text(''),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          buildProfileOption(context, 'Personal Details'),
          buildProfileOption(context, 'Password & Security'),
          buildProfileOption(context, 'Payment & Shipping'),
          buildProfileOption(context, 'Sign Out', isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget buildProfileOption(BuildContext context, String title, {bool isLogout = false}) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (isLogout) {

          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signup(),));
          }
        },
      ),
    );
  }
}
