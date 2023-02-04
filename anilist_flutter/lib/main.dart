import 'package:anilist_flutter/assets/colors.dart';
import 'package:anilist_flutter/screens/anime_details/anime_details.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'screens/home_page/home_page.dart';

Future main() async {
  await initHiveForFlutter();

  runApp(AnilistApp());
}

class AnilistApp extends StatelessWidget {
  AnilistApp({super.key});

  ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
    GraphQLClient(
      link: HttpLink("https://graphql.anilist.co/"),
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: MyColors.backgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: MyColors.lisTiletextColor, fontFamily: 'Nunito')),
      title: "Anilist Flutter",
      home: HomePage(client: client),
    );
  }
}
