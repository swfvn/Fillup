import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  User? _user;
  String? _profileImageUrl;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isEditing = false;

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
        _emailController.text = userData?['email'] ?? user.email ?? '';
        _phoneController.text = userData?['phone'] ?? '';
        _addressController.text = userData?['address'] ?? '';
      });
    }
  }

  Future<String> _uploadProfileImage(File image, String userId) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$userId');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _updateProfile() async {
    try {
      if (_user == null) return;

      String name = _nameController.text.trim();
      String phone = _phoneController.text.trim();
      String address = _addressController.text.trim();
      String userId = _user!.uid;

      Map<String, String> userData = {
        "name": name,
        "phone": phone,
        "address": address,
      };

      if (_profileImage != null) {
        String imageUrl = await _uploadProfileImage(_profileImage!, userId);
        userData["profileImage"] = imageUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully')),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile.')),
      );
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
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
                        onTap: _isEditing ? _pickImage : null,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 65.0,
                              backgroundColor: Colors.yellow,
                              child: CircleAvatar(
                                radius: 60.0,
                                backgroundImage: _profileImageUrl != null
                                    ? CachedNetworkImageProvider(_profileImageUrl!)
                                    : CachedNetworkImageProvider('https://via.placeholder.com/150'), // Default placeholder
                                child: _profileImageUrl == null
                                    ? Icon(Icons.camera_alt, color: Colors.black)
                                    : null,
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Icon(
                                  Icons.add_a_photo_rounded,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.person),
                          labelText: "Name",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        readOnly: !_isEditing,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.phone),
                          labelText: "Phone",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        readOnly: !_isEditing,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.mail),
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        readOnly:true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.house_alt),
                          labelText: "Address",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        readOnly: !_isEditing,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_isEditing) {
                              await _updateProfile();
                              _toggleEditMode();
                            } else {
                              _toggleEditMode();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            minimumSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            _isEditing ? "Update Profile" : "Edit Profile",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
