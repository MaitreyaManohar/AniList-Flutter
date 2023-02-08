import 'package:anilist_flutter/assets/colors.dart';
import 'package:anilist_flutter/screens/character_screen/character_details.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CharacterList extends StatelessWidget {
  String animeTitle = " ";
  String query = "";
  final _scrollController = ScrollController();
  bool check = false;
  int page = 1;
  late ValueNotifier<GraphQLClient> client;
  CharacterList({super.key, required this.animeTitle}) {
    final HttpLink httpLink = HttpLink("https://graphql.anilist.co/");
    client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
      ),
    );
    query = """
query ReadCharacters(\$animeTitle: String!,\$page: Int!){
  Media(search:\$animeTitle){
    characters(page:\$page,perPage:10) {
      nodes{
        id
        name {
          
          full
          userPreferred
        }
        image {
          medium
        }
      }
      
    }
    
  }
}

""";
  }
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.backgroundColor,
          centerTitle: true,
          title: Text("Characters of ${animeTitle.trim()}"),
        ),
        body: Query(
          options: QueryOptions(
            document: gql(query),
            variables: {
              'animeTitle': animeTitle.trim(),
              'page': page,
            },
          ),
          builder: (result, {fetchMore, refetch}) {
            if (result.isLoading && result.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (result.data!['Media']['characters']['nodes'].isEmpty) {
              return const Center(child: Text("No character data"));
            }
            return NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    _scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent &&
                    check == false &&
                    result.data!['Media']['characters']['nodes'].length >= 10) {
                  FetchMoreOptions opts = FetchMoreOptions(
                      updateQuery: ((previousResultData, fetchMoreResultData) {
                        if (fetchMoreResultData!['Media']['characters']['nodes']
                            .isEmpty) {
                          check = true;
                          return previousResultData;
                        }
                        final List repos = [
                          ...previousResultData!['Media']['characters']
                              ['nodes'],
                          ...fetchMoreResultData['Media']['characters']['nodes']
                        ];
                        fetchMoreResultData['Media']['characters']['nodes'] =
                            repos;
                        return fetchMoreResultData;
                      }),
                      variables: {'page': ++page});
                  fetchMore!(opts);
                }
                return true;
              },
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: (check == false &&
                          result.data!['Media']['characters']['nodes'].length >=
                              10)
                      ? (result.data?['Media']['characters']['nodes'].length +
                          1)
                      : result.data?['Media']['characters']['nodes'].length,
                  itemBuilder: ((context, index) {
                    if (index ==
                            result
                                .data?['Media']['characters']['nodes'].length &&
                        check == false) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) => CharacterDetails(
                                  id: result.data?['Media']['characters']
                                      ['nodes'][index]['id'],
                                  characterName: result.data?['Media']
                                          ['characters']['nodes'][index]['name']
                                      ['full']))));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 150,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)),
                              child:
                                  // ListTile(
                                  //   onTap: () {
                                  //     Navigator.of(context).push(MaterialPageRoute(
                                  //         builder: ((context) => CharacterDetails(
                                  //             characterName: result.data?['Media']
                                  //                     ['characters']['nodes'][index]
                                  //                 ['name']['full']))));
                                  //   },
                                  //   leading: Image.network(
                                  //     result.data?['Media']['characters']['nodes']
                                  //         [index]['image']['medium'],
                                  //     fit: BoxFit.fill,
                                  //   ),
                                  //   title: Text(result.data?['Media']['characters']
                                  //       ['nodes'][index]['name']['full']),
                                  // ),
                                  Row(
                                children: [
                                  Image.network(
                                    result.data?['Media']['characters']['nodes']
                                        [index]['image']['medium'],
                                    fit: BoxFit.cover,
                                    width: 150,
                                  ),
                                  const SizedBox(
                                    width: 50,
                                  ),
                                  Flexible(
                                    child: Text(
                                      result.data?['Media']['characters']
                                          ['nodes'][index]['name']['full'],
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      );
                    }
                  })),
            );
          },
        ),
      ),
    );
  }
}
