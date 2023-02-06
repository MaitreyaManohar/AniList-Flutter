import 'package:anilist_flutter/assets/colors.dart';
import 'package:anilist_flutter/screens/character_list/character_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart' as lib2;
import 'package:graphql_flutter/graphql_flutter.dart';

class AnimeDetails extends StatelessWidget {
  final String title;
  late ValueNotifier<GraphQLClient> client;
  late String query;
  late String recommendationsQuery;
  int page = 1;
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
    query = """query {
  Media(search:"${title.trim()}"){
    id
    status
    title{
      english
    }
    episodes
    genres
    coverImage{
      large
    }
  }
  
}""";

    recommendationsQuery = """
query RecommendationsQuery(\$id: Int!,\$page: Int!){
  Page(page:\$page,perPage:10){
 		recommendations(mediaRecommendationId:\$id){
  	media{
      coverImage{
        medium
      }
    title {
      romaji
      english
      native
      userPreferred
    }
  }
}
}
}""";
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
          backgroundColor: MyColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: MyColors.backgroundColor,
            centerTitle: true,
            title: Text(title.trim()),
            actions: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Something went wrong");
                  }
                  if (snapshot.hasData) {
                    return IconButton(
                      onPressed: () async {
                        final userDoc = FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid);
                        List bookmarks =
                            snapshot.data!.data()!['bookmarks'] ?? [];
                        if (bookmarks.contains(title)) {
                          bookmarks.remove(title);
                        } else {
                          bookmarks.add(title);
                        }
                        await userDoc.set(
                            {'bookmarks': bookmarks}, SetOptions(merge: true));
                      },
                      icon: Icon(
                          snapshot.data!.data()!['bookmarks'].contains(title)
                              ? Icons.bookmark
                              : Icons.bookmark_outline),
                    );
                  } else {
                    return const Text("Loading");
                  }
                },
              )
            ],
          ),
          body: lib2.Query(
            options: QueryOptions(document: gql(query)),
            builder: (result, {fetchMore, refetch}) {
              if (result.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: [
                  Center(
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.network(
                            result.data?['Media']['coverImage']['large'],
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 3,
                            fit: BoxFit.fitWidth,
                          ),
                          Text("STATUS: ${result.data?['Media']['status']}"),
                          Text("Genres: ${result.data?['Media']['genre']}"),
                          Text(
                              "EPISODES: ${result.data?['Media']['episodes']}"),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: ((context) =>
                                      CharacterList(animeTitle: title)),
                                ),
                              );
                            },
                            child: const Text("Click here to view characters"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "Recommendations",
                    style: TextStyle(color: MyColors.labelColor, fontSize: 20),
                  ),
                  lib2.Query(
                    options: QueryOptions(
                        document: gql(recommendationsQuery),
                        variables: {
                          'id': result.data?['Media']['id'],
                          'page': 1
                        }),
                    builder: (result2, {fetchMore, refetch}) {
                      if (result2.isLoading) {
                        return const CircularProgressIndicator();
                      }
                      if (result2.data?['Page']['recommendations'].isEmpty) {
                        return Center(
                          child: Text(
                            "No recommendations available",
                            style: TextStyle(color: MyColors.labelColor),
                          ),
                        );
                      }
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              result2.data?['Page']['recommendations'].length,
                          itemBuilder: (context, index) {
                            final title = (result2.data!['Page']
                                            ['recommendations'][index]['media']
                                        ['title']['english'] ==
                                    null)
                                ? result2.data!['Page']['recommendations']
                                    [index]['media']['title']['native']
                                : result2.data!['Page']['recommendations']
                                    [index]['media']['title']['english'];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) =>
                                      AnimeDetails(title: title),
                                ));
                              },
                              child: SizedBox(
                                width: 200,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      Image.network(
                                        result2.data!['Page']['recommendations']
                                                [index]['media']['coverImage']
                                            ['medium'],
                                        fit: BoxFit.fitWidth,
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                      ),
                                      Text(
                                        (title == null)
                                            ? result2.data!['Page']
                                                    ['recommendations'][index]
                                                ['media']['title']['romaji']
                                            : title,
                                        overflow: TextOverflow.fade,
                                        style: const TextStyle(
                                          fontSize: 14.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                ],
              );
            },
          )),
    );
  }
}
