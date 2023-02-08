import 'package:anilist_flutter/screens/home_page/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../assets/colors.dart';

class LogIn extends StatelessWidget {
  LogIn({super.key});
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _forgotpasswordController = TextEditingController();
  ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
    GraphQLClient(
      link: HttpLink("https://graphql.anilist.co/"),
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    ),
  );

  void message(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(content: Text(message)),
    );
  }

  void loading(BuildContext context) {
    //Loading Progress indicator
    showDialog(
        context: context,
        builder: ((context) => const Center(
              child: CircularProgressIndicator(),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: MyColors.backgroundColor,
        centerTitle: true,
        title: const Text("AniList"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(
            child: Icon(
              Icons.lock_outline,
              size: 150,
              color: Color.fromARGB(200, 255, 255, 255),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: "Enter email",
                          fillColor: Colors.white70),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.grey[800]),
                          hintText: "Enter password",
                          fillColor: Colors.white70),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.only(top: 16.0),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      loading(context);
                      if (!EmailValidator.validate(
                          _emailController.text.trim())) {
                        Navigator.pop(context);
                        message(context, "Enter a valid email");
                        return;
                      }
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text);
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(client: client),
                            ));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                  "You do not have an account. Do you want to create an account?"),
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: _confirmpasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        filled: true,
                                        hintStyle:
                                            TextStyle(color: Colors.grey[800]),
                                        hintText: "Confirm password",
                                        fillColor: Colors.white70),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          loading(context);
                                          if (_confirmpasswordController.text !=
                                              _passwordController.text) {
                                            Navigator.pop(context);
                                            message(context,
                                                "Passwords do not match!");
                                            return;
                                          }
                                          try {
                                            UserCredential user = await FirebaseAuth
                                                .instance
                                                .createUserWithEmailAndPassword(
                                                    email: _emailController.text
                                                        .trim(),
                                                    password:
                                                        _passwordController
                                                            .text);
                                            final userDoc = FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(user.user!.uid.toString());
                                            await userDoc.set({
                                              'email':
                                                  _emailController.text.trim()
                                            });
                                            Navigator.popUntil(context,
                                                (route) => route.isFirst);
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage(client: client),
                                                ));
                                          } on FirebaseAuthException catch (e) {
                                            Navigator.pop(context);
                                            message(context, e.toString());
                                          }
                                        },
                                        child: const Text("Yes")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("No")),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                          message(context, e.toString());
                        }
                      }
                    },
                    child: const Text("Login"),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                              "Please enter your email in the underlying text field"),
                          actions: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _forgotpasswordController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[800]),
                                    hintText: "Confirm email",
                                    fillColor: Colors.white70),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () async {
                                      if (!EmailValidator.validate(
                                          _forgotpasswordController.text)) {
                                        message(context,
                                            "Please enter a valid email");
                                        return;
                                      }
                                      try {
                                        loading(context);
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                                email: _forgotpasswordController
                                                    .text.trim());
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        message(context,
                                            "A reset password email has been sent");
                                      } on FirebaseAuthException catch (e) {
                                        Navigator.pop(context);
                                        message(context, e.toString());
                                      }
                                    },
                                    child: const Text("Yes")),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("No")),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      "Forgot password",
                      style: TextStyle(color: Colors.blue, fontSize: 11.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
