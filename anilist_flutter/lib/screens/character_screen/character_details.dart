import 'package:anilist_flutter/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CharacterDetails extends StatelessWidget {
  final String characterName;
  late ValueNotifier<GraphQLClient> client;
  late String query;
  final int id;
  CharacterDetails({super.key, required this.characterName,required this.id}) {
    final HttpLink httpLink = HttpLink("https://graphql.anilist.co/");
    client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
      ),
    );
    query = """query Character(\$id:Int!){
  Character(id:\$id){
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
            backgroundColor: MyColors.backgroundColor,
            centerTitle: true,
            title: Text(characterName.trim()),
          ),
          body: Query(
            options: QueryOptions(
                document: gql(query),
                variables: {'characterName': characterName,'id':id}),
            builder: (result, {fetchMore, refetch}) {
              if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Description",
                            style: TextStyle(
                                fontSize: 25, color: MyColors.labelColor),
                          ),
                          Text(
                            "${(result.data?['Character']['description'] == null) ? "No data " : result.data?['Character']['description']}",
                            style: TextStyle(color: MyColors.labelColor),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Gender : ${(result.data?['Character']['gender'] == null) ? "No data" : result.data?['Character']['gender']}",
                        style:
                            TextStyle(fontSize: 25, color: MyColors.labelColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Age : ${(result.data?['Character']['age'] == null) ? "No data" : result.data?['Character']['age'] }",
                        style:
                            TextStyle(fontSize: 25, color: MyColors.labelColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "BloodType : ${(result.data?['Character']['bloodType'] == null) ? "No data" : result.data?['Character']['bloodType']}",
                        style:
                            TextStyle(fontSize: 25, color: MyColors.labelColor),
                      ),
                    )
                  ],
                ),
              );
            },
          )),
    );
  }
}
