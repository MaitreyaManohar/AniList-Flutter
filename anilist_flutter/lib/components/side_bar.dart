import 'package:anilist_flutter/screens/bookmarks/bookmarks.dart';
import 'package:anilist_flutter/screens/home_page/components/anime_dashboard.dart';
import 'package:anilist_flutter/screens/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            title: const Text("Browse"),
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
            title: const Text("Bookmarked"),
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
