import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  await initHiveForFlutter();
  final HttpLink httpLink = HttpLink("");
  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
    // OR
    // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
  runApp(const AnilistApp());
}

class AnilistApp extends StatelessWidget {
  const AnilistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}