import 'package:anilist_flutter/screens/anime_details/anime_details.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'screens/home_page/home_page.dart';

void main() async {
  await initHiveForFlutter();
  final HttpLink httpLink = HttpLink("https://graphql.anilist.co/");
  final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    ),
  );

  runApp(MaterialApp(
    
    title: "Anilist Flutter",
    home: HomePage(client: client),
  ));
}
