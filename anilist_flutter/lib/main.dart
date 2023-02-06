import 'package:anilist_flutter/assets/colors.dart';
import 'package:anilist_flutter/screens/home_page/home_page.dart';
import 'package:anilist_flutter/screens/log_in/log_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: MyColors.backgroundColor,
          textTheme: Theme.of(context).textTheme.apply(
              bodyColor: MyColors.lisTiletextColor, fontFamily: 'Nunito')),
      title: "Anilist Flutter",
      home: (user == null) ? LogIn() : HomePage(client: client),
    );
  }
}
