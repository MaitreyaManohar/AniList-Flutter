import 'package:anilist_flutter/assets/colors.dart';
import 'package:anilist_flutter/screens/bookmarks/bookmarks.dart';
import 'package:anilist_flutter/screens/home_page/components/anime_dashboard.dart';
import 'package:anilist_flutter/screens/home_page/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: MyColors.backgroundColor,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            color: Colors.white,
            width: double.infinity,
            child: Center(
                child: Text(
                    "Welcome ${FirebaseAuth.instance.currentUser!.email}")),
          ),
          ListTile(
            title: Text("Browse",
                style: TextStyle(color: MyColors.labelColor, fontSize: 20)),
            onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                      client: ValueNotifier<GraphQLClient>(
                    GraphQLClient(
                      link: HttpLink("https://graphql.anilist.co/"),
                      cache: GraphQLCache(
                        store: HiveStore(),
                      ),
                    ),
                  )),
                )),
          ),
          ListTile(
            title: Text("Bookmarked",
                style: TextStyle(color: MyColors.labelColor, fontSize: 20)),
            onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookMarks(),
                )),
          )
        ],
      ),
    );
  }
}
