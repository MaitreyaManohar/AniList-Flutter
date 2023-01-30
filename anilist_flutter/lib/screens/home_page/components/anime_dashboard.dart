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
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (page < 10 &&
        (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent)) {
              print("HELLO");
      setState(() {
        query = """ 
  query{
  Page(page:$page,perPage:10){
    media(sort:POPULARITY){
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
        page++;
      });
    }
  }

  String query = """ 
  query{
  Page(page:1,perPage:100){
    media(sort:POPULARITY){
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
          onChanged: (value) {
            setState(
              () {
                if (value == "") {
                  query = """ 
  query{
  Page(page:$page,perPage:100){
    media(sort:TRENDING){
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
  query{
  Page(page:$page,perPage:100){
    media(sort:TRENDING,search:"$value"){
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
          options: QueryOptions(document: gql(query)),
          builder: ((result, {fetchMore, refetch}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            } else if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              final List animeMediaList = result.data?['Page']['media'];
              animeMediaList
                  .retainWhere((element) => element['isAdult'] == false);
              animeMediaList.removeWhere((element) =>
                  (element['title']['english'] == null &&
                      element['title']['native'] == null));
              return Flexible(
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: animeMediaList.length,
                  itemBuilder: ((context, index) {
                    String animeTitle;
                    final animeNamesEnglish =
                        animeMediaList[index]['title']['english'];
                    final animeNamesNative =
                        animeMediaList[index]['title']['native'];

                    if (animeNamesEnglish != null) {
                      animeTitle = animeNamesEnglish;
                    } else if (animeNamesNative != null) {
                      animeTitle = animeNamesNative;
                    } else {
                      animeTitle = "NONE";
                    }
                    return AnimeCard(
                      image: animeMediaList[index]['coverImage']['medium'],
                      title: animeTitle,
                    );
                  }),
                ),
              );
            }
          }),
        ),
      ],
    );
  }
}
