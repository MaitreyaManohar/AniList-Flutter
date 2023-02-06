import 'package:anilist_flutter/assets/colors.dart';
import 'package:anilist_flutter/screens/home_page/components/anime_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../components/side_bar.dart';
import '../log_in/log_in.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    required this.client,
  }) : super(key: key);
  void loading(BuildContext context) {
    //Loading Progress indicator
    showDialog(
        context: context,
        builder: ((context) => const Center(
              child: CircularProgressIndicator(),
            )));
  }

  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
          drawer: const SideBar(),
          backgroundColor: MyColors.backgroundColor,
          appBar: AppBar(
            actions: [
              TextButton(
                style:
                    TextButton.styleFrom(backgroundColor: Colors.transparent),
                onPressed: () async {
                  loading(context);
                  await FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: ((context) => LogIn())));
                },
                child: const Text(
                  'SignOut',
                ),
              )
            ],
            backgroundColor: MyColors.backgroundColor,
            centerTitle: true,
            title: const Text("AniList"),
          ),
          body: const AnimeDashboard()),
    );
  }
}
