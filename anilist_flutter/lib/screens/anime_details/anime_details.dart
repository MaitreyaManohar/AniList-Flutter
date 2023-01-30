import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AnimeDetails extends StatelessWidget {
  final String title;
  late ValueNotifier<GraphQLClient> client;
  late String query;
  AnimeDetails({super.key, required this.title}) {
    final HttpLink httpLink = HttpLink("https://graphql.anilist.co/");
    client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
      ),
    );
    query = """query{
  Media(search:"$title"){
    coverImage{
      large
    }
  }
}""";
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(title),
          ),
          body: Query(
            options: QueryOptions(document: gql(query)),
            builder: (result, {fetchMore, refetch}) {
              if(result.isLoading){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    result.data?['Media']['coverImage']['large'],
                    height: 300,
                    fit:BoxFit.cover
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Click here for characters"),
                  ),
                ],
              );
            },
          )),
    );
  }
}
