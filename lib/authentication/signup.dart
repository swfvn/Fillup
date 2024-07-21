import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiil_up_app/authentication/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SigninState();
}

class _SigninState extends State<Signup> {
  bool isobscuretext = true;
  bool isobscuretext1 = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final  TextEditingController _Name =TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();
      String Name=_Name.text.trim();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
// create
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final FirebaseFirestore firestore =FirebaseFirestore.instance;
      await  firestore.collection('Registration').doc(userCredential.user!.uid).set({
        "email":email,
        "Name":Name
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful')),


      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text("Signup",style:
              TextStyle(color: Colors.black,
                  fontStyle: FontStyle.italic,fontSize: 50,fontWeight: FontWeight.bold),),
            )),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top: 50),
              child: TextField(
                controller: _Name,
                decoration: InputDecoration(
                    labelText: "Name",
                    suffixIcon: Icon(Icons.person),
                    border: OutlineInputBorder()
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: "Email",
                    suffixIcon: Icon(Icons.mail),
                    border: OutlineInputBorder()
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
              child: TextField(
                obscureText: isobscuretext,
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isobscuretext ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: (){
                        setState(() {
                          isobscuretext = !isobscuretext;
                        });
                      },
                    ),
                    border: OutlineInputBorder()
                ),
              ),
            ),Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
              child: TextField(
                obscureText: isobscuretext1,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                    labelText: " Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isobscuretext1 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: (){
                        setState(() {
                          isobscuretext1 = !isobscuretext1;
                        });
                      },
                    ),
                    border: OutlineInputBorder()
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30,right: 10,left: 10),
              child: ElevatedButton(onPressed: _register,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black,
                      minimumSize: Size(200, 50)),
                  child: Text("Signup",style: TextStyle(
                      color: Colors.yellow,fontSize: 30),)),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30,top: 35),
                  child: Text("Already have an account? ",style: TextStyle(fontSize: 20),),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: TextButton(onPressed:() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
                  }, child: Text("Login",
                    style: TextStyle(fontSize: 20,
                        color: Colors.blue,fontStyle: FontStyle.italic),)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}