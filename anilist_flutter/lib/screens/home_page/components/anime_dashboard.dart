import 'package:anilist_flutter/screens/home_page/components/animeCard.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AnimeDashboard extends StatefulWidget {
  const AnimeDashboard({super.key});

  @override
  State<AnimeDashboard> createState() => _AnimeDashboardState();
}

class _AnimeDashboardState extends State<AnimeDashboard> {
  int page = 1;
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  bool _check = false;
  String query = """ 
  query AnimeDashboard(\$page: Int!){
  Page(page:\$page,perPage:10){
    media(isAdult:false){
      id
      isAdult
      coverImage{
        medium
      }
      title{
        english,
        native
        
      }
    }
  }
}
  """;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textController,
          onChanged: (value) {
            setState(
              () {
                if (value == "") {
                  print("Yess");
                  query = """ 

  query AnimeDashboard(\$page: Int!){
  Page(page:\$page,perPage:10){
    media(isAdult:false){
      id
      isAdult
      coverImage{
        medium
      }
      title{
        english,
        native
        
      }
    }
  }
}
  """;
                } else {
                  page = 1;
                  query = """ 
  query AnimeDashboard(\$page: Int!,\$value: String!){
  Page(page:\$page,perPage:10){
    media(search:\$value,isAdult:false){
      id
      isAdult
      coverImage{
        medium
      }
      title{
        english,
        native
        
      }
    }
  }
}
  """;
                }
              },
            );
          },
          cursorColor: Colors.grey,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 20)),
              hintText: 'Search',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
              prefixIcon: Container(
                padding: const EdgeInsets.all(15),
                width: 18,
                child: const Icon(Icons.search),
              )),
        ),
        Query(
          options: QueryOptions(
              document: gql(query),
              variables: {'page': page, 'value': _textController.text}),
          builder: ((result, {fetchMore, refetch}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            } else if (result.isLoading && result.data == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              // final List animeMediaList = result.data?['Page']['media'];
              // animeMediaList
              //     .retainWhere((element) => element['isAdult'] == false);
              // animeMediaList.removeWhere((element) =>
              //     (element['title']['english'] == null &&
              //         element['title']['native'] == null));
              return Flexible(
                child: NotificationListener(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        _scrollController.position.pixels ==
                            _scrollController.position.maxScrollExtent &&
                        _check == false) {
                      
                      FetchMoreOptions opts = FetchMoreOptions(
                          updateQuery:
                              (previousResultData, fetchMoreResultData) {
                            if (fetchMoreResultData!['Page']['media'].isEmpty) {
                              _check = true;
                              return previousResultData;
                            }
                            final List repos = [
                              ...previousResultData!['Page']['media'],
                              ...fetchMoreResultData['Page']['media']
                            ];

                            fetchMoreResultData['Page']['media'] = repos;
                            return fetchMoreResultData;
                          },
                          variables: {
                            'page': ++page,
                            'value': _textController.text
                          });
                      fetchMore!(opts);
                    }
                    return true;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: (_check == false &&
                            result.data!['Page']['media'].length >= 10)
                        ? (result.data!['Page']['media'].length + 1)
                        : result.data!['Page']['media'].length,
                    itemBuilder: ((context, index) {
                      if (index == result.data?['Page']['media'].length &&
                          _check == false) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      String animeTitle;
                      final animeNamesEnglish = result.data!['Page']['media']
                          [index]['title']['english'];
                      final animeNamesNative = result.data!['Page']['media']
                          [index]['title']['native'];

                      if (animeNamesEnglish != null) {
                        animeTitle = animeNamesEnglish;
                      } else if (animeNamesNative != null) {
                        animeTitle = animeNamesNative;
                      } else {
                        animeTitle = "NONE";
                      }
                      print(result.data!['Page']['media'][index]['id']);
                      return AnimeCard(
                        image: result.data!['Page']['media'][index]
                            ['coverImage']['medium'],
                        title: animeTitle,
                        id:result.data!['Page']['media'][index]['id']
                      );
                    }),
                  ),
                ),
              );
            }
          }),
        ),
      ],
    );
  }
}
