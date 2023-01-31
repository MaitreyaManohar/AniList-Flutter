import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CharacterDetails extends StatelessWidget {
  final String characterName;
  late ValueNotifier<GraphQLClient> client;
  late String query;
  CharacterDetails({super.key, required this.characterName}) {
    final HttpLink httpLink = HttpLink("https://graphql.anilist.co/");
    client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
      ),
    );
    query = """query Character(\$characterName: String!){
  Character(search:\$characterName){
    image{
      large
    }
    description
    dateOfBirth {
      year
      month
      day
    }
    gender
    age
    bloodType
    
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
            title: Text(characterName.trim()),
          ),
          body: Query(
            options: QueryOptions(
                document: gql(query),
                variables: {'characterName': characterName}),
            builder: (result, {fetchMore, refetch}) {
              if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      result.data?['Character']['image']['large'],
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  Text(result.data?['Character']['description']),
                  Text("Gender : ${result.data?['Character']['gender']}"),
                  Text("Age : ${result.data?['Character']['age']}"),
                  Text(
                      "BloodType : ${(result.data?['Character']['bloodType'] == null) ? "No data" : result.data?['Character']['bloodType']}")
                ],
              );
            },
          )),
    );
  }
}
