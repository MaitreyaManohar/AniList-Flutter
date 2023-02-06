import 'package:anilist_flutter/screens/home_page/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../assets/colors.dart';

class LogIn extends StatelessWidget {
  LogIn({super.key});
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                      padding: const EdgeInsets.all(16.0),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      if (!EmailValidator.validate(
                          _emailController.text.trim())) {
                        message(context, "Enter a valid email");
                        return;
                      }
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(client: client),
                            ));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          UserCredential user = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text);
                          final userDoc = FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.user!.uid.toString());
                          await userDoc
                              .set({'email': _emailController.text.trim()});
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(client: client),
                              ));
                        }
                      }
                    },
                    child: const Text("Login"),
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
