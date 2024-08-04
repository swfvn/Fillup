import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiil_up_app/authentication/updatepass.dart';
import 'package:fiil_up_app/profile/editprofile.dart';
import 'package:fiil_up_app/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? _user;
  String? _profileImageUrl;
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      setState(() {
        _user = user;
        _profileImageUrl = userData?['profileImage'] ?? user.photoURL;
        _nameController.text = userData?['name'] ?? user.displayName ?? '';
      });
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

                      CircleAvatar(
                        radius: 65.0,
                        backgroundColor: Colors.yellow,
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundImage: _profileImageUrl != null
                              ? CachedNetworkImageProvider(_profileImageUrl!)
                              : CachedNetworkImageProvider('https://via.placeholder.com/150'),
                          child: _profileImageUrl == null
                              ? Icon(Icons.camera_alt, color: Colors.black)
                              : null,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        _nameController.text.isNotEmpty ? _nameController.text : 'No Name',
                        style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        _user!.email ?? 'No email',
                        style: TextStyle(color: Colors.black),
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                buildProfileOption(context, 'Edit Profile'),
                buildProfileOption(context, 'Change Password'),
                buildProfileOption(context, 'Help & Support'),
                SizedBox(height: 80.0),
                buildProfileOption(context, 'Logout',isLogout: true),
                SizedBox(height: 20.0),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget buildProfileOption(BuildContext context, String title, {bool isLogout = false}) {
    return SizedBox(
      height:60,
      child: Card(
        color: isLogout ? Colors.red : Colors.white,
        child: ListTile(
          title: Text(title, style: TextStyle(color: isLogout ? Colors.white : Colors.black)),
          trailing:  isLogout ? Icon(Icons.logout, color:Colors.white) :Icon(Icons.arrow_forward_ios, color: Colors.black),
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
      ),
    );
  }


  Widget _getPageForTitle(String title) {
    switch (title) {
      case 'Edit Profile':
        return EditProfile();
      case 'Change Password':
        return UpdatePassword();
      // case 'Help & Support':
      //   return PasswordSecurityPage();
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

