import 'dart:io';

import 'package:fiil_up_app/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? _user;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Ensure we get the latest data
      setState(() {
        _user = FirebaseAuth.instance.currentUser;
        _profileImageUrl = user.photoURL;
      });
    }
  }

  Future<void> _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      try {
        // Upload to Firebase Storage
        String fileName = 'profile_images/${_user!.uid}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        await storageRef.putFile(file);

        // Get download URL
        String downloadURL = await storageRef.getDownloadURL();

        // Update user profile
        await _user!.updatePhotoURL(downloadURL);

        // Update state
        setState(() {
          _profileImageUrl = downloadURL;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image updated successfully!')),
        );
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile image.')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SplashScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: _uploadImage,
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : NetworkImage(
                            'https://via.placeholder.com/150', // Default placeholder
                          ),
                          child: _profileImageUrl == null
                              ? Icon(Icons.camera_alt, color: Colors.white)
                              : null,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        _user!.displayName ?? 'User Name',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        _user!.email ?? 'No email',
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: _uploadImage,
                        child: Text('Change Profile Picture'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                buildProfileOption(context, 'Personal Details'),
                buildProfileOption(context, 'Password & Security'),
                buildProfileOption(context, 'Payment & Shipping'),
                SizedBox(height: 20.0),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 300),
            child: ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                minimumSize: Size(double.maxFinite, 40),
              ),
              child: Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileOption(BuildContext context, String title, {bool isLogout = false}) {
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.black)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: () {
          if (isLogout) {
            _signOut();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _getPageForTitle(title)),
            );
          }
        },
      ),
    );
  }

  Widget _getPageForTitle(String title) {
    switch (title) {
      case 'Personal Details':
        return PersonalDetailsPage();
      case 'Password & Security':
        return PasswordSecurityPage();
      case 'Payment & Shipping':
        return PaymentShippingPage();
      default:
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
          ),
          body: Center(
            child: Text('Page not found', style: TextStyle(color: Colors.black)),
          ),
        );
    }
  }
}

class PersonalDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Details'),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Personal Details Page', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}

class PasswordSecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password & Security'),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Password & Security Page', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}

class PaymentShippingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment & Shipping'),
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Payment & Shipping Page', style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
