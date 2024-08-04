// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/firebase_firestore_helper.dart';
import '../services/shared_preferences_helper.dart';
import 'forget_password.dart';
import 'sign_up_screen.dart';
import 'package:chat_app/screens/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "", password = "";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isVisible = true;

  userLogin() async {
    try {
      _emailController.clear();
      _passwordController.clear();

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print(e.message);
        }
      }
      String? name, username, pic, id;

      try {
        QuerySnapshot querySnapshot =
            await FireStoreHelper().getUserbyEmail(email);

        name = "${querySnapshot.docs[0]["Name"]}";
        username = "${querySnapshot.docs[0]["Username"]}";
        pic = "${querySnapshot.docs[0]["Photo"]}";
        id = "${querySnapshot.docs[0]["Id"]}";
      } on FirebaseAuthException catch (e) {
        print(e.code);
      }
      await SharedPreferenceHelper().saveUserDisplayName(name!);
      await SharedPreferenceHelper().saveUserPhoto(pic!);
      await SharedPreferenceHelper().saveUserName(username!);
      await SharedPreferenceHelper().saveUserId(id!);
      await SharedPreferenceHelper().saveEmailKey(email);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) {
        return const HomeScreen();
      }));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("User Does Not Exist")));
      } else if (e.code == "wrong-password") {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Wrong Password")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: mq.height / 4,
            width: mq.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade300, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(mq.width, 105))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                const Center(
                  child: Text(
                    "Please sign in to continue",
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 20),
                      height: mq.height / 2,
                      width: mq.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.0, color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextFormField(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  controller: _emailController,
                                  validator: (value) {
                                    if (value == null || value == "") {
                                      return "Please Enter Email";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Email",
                                      prefixIcon: Icon(Icons.email_outlined),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15)),
                                )),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Password",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1.0, color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextFormField(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  validator: (value) {
                                    if (value == null || value == "") {
                                      return "Please Enter Password";
                                    }
                                    return null;
                                  },
                                  controller: _passwordController,
                                  obscureText: _isVisible,
                                  decoration: InputDecoration(
                                      hintText: "Password",
                                      prefixIcon:
                                          const Icon(Icons.lock_outlined),
                                      suffixIcon: _isVisible
                                          ? IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isVisible = false;
                                                });
                                              },
                                              icon: const Icon(
                                                  Icons.visibility_outlined))
                                          : IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isVisible = true;
                                                });
                                              },
                                              icon: const Icon(Icons
                                                  .visibility_off_outlined)),
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 15)),
                                )),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) {
                                  return const ForgetPasswordScreen();
                                }));
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: const Text(
                                  "Forget Password ?",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15.0,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    email = _emailController.text.trim();
                                    password = _passwordController.text.trim();
                                  });
                                }
                                userLogin();
                              },
                              child: Center(
                                child: SizedBox(
                                  width: 130,
                                  child: Material(
                                    elevation: 5,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(10),
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red.shade600,
                                      ),
                                      child: const Text(
                                        "SignIn",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()));
                      },
                      child: const Text(
                        "SignUp",
                        style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
