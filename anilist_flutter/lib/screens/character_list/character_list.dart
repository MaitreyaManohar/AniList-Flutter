import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CharacterList extends StatelessWidget {
  String animeTitle = " ";
  String query = "";
  final _scrollController = ScrollController();

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
  bool check = false;
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
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
            return NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    _scrollController.position.pixels ==
                        _scrollController.position.maxScrollExtent &&
                    check == false) {
                  print("hello");
                  FetchMoreOptions opts = FetchMoreOptions(
                      updateQuery: ((previousResultData, fetchMoreResultData) {
                        print(fetchMoreResultData);
                        if (fetchMoreResultData!['Media']['characters']['nodes']
                            .isEmpty) {
                          print("YES");
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
                  itemCount:
                      result.data?['Media']['characters']['nodes'].length,
                  itemBuilder: ((context, index) {
                    if (result.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: Image.network(
                          result.data?['Media']['characters']['nodes'][index]
                              ['image']['medium'],
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(result.data?['Media']['characters']['nodes']
                            [index]['name']['full']),
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
