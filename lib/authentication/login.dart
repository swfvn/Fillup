
import 'package:fiil_up_app/admin/adminhome.dart';
import 'package:fiil_up_app/authentication/signup.dart';
import 'package:fiil_up_app/selectionhome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}
class _LoginState extends State<Login> {
  bool isobscuretext = true;
  final TextEditingController _emailController =TextEditingController();
  final TextEditingController _passwordController =TextEditingController();
  final FirebaseAuth _auth =FirebaseAuth.instance;

  Future<void> _Login(BuildContext context) async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (email=='muhammedswafvan123@gmail.com'){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Adminhomeee(),));
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeSelection(),));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in Successful')),
      );
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: $e')),
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
              padding: const EdgeInsets.only(top: 80),
              child: Text("Login",style: TextStyle(color: Colors.black,fontSize: 50,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
            )),
            Padding(
              padding: const EdgeInsets.only(left: 10,top: 50,right: 10),
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
              padding: const EdgeInsets.only(left: 10,top: 20,right: 10),
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
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10,left: 10,top: 30),
              child: ElevatedButton(onPressed: () => _Login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,minimumSize: Size(200, 50), ),
                  child: Text("Login",style:
                  TextStyle(color: Colors.yellow,
                      fontWeight: FontWeight.bold,fontSize: 30),)),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30,top: 35),
                  child: Text("Don't Have an Account ?",style: TextStyle(fontSize: 20),),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 35),
                  child: TextButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Signup(),));
                  }, child: Text("Sign Up",style:
                  TextStyle(color: Colors.blue,fontSize: 18),)),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}