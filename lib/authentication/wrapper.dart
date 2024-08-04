import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiil_up_app/profile/adduserprofile.dart';
import 'package:fiil_up_app/authentication/login.dart';
import 'package:fiil_up_app/selectionhome.dart';
import 'package:fiil_up_app/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Login();
        } else {
          return CheckUserProfile(user: snapshot.data!);
        }
      },
    );
  }
}


class CheckUserProfile extends StatelessWidget {
  final User user;

  CheckUserProfile({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
            if (userData.containsKey('name') && userData.containsKey('phone') && userData.containsKey('address')) {
              return HomeSelection();
            } else {
              return UserProfilePage(user: user);
            }
          } else {
            return UserProfilePage(user: user);
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}