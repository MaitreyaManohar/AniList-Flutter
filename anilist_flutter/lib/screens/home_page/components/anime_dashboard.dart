import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AnimeDashboard extends StatefulWidget {
  const AnimeDashboard({super.key});

  @override
  State<AnimeDashboard> createState() => _AnimeDashboardState();
}

class _AnimeDashboardState extends State<AnimeDashboard> {
  String query = """ 
  query{
  Page(page:1,perPage:100){
    media(sort:POPULARITY){
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
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(
                () {
                  if (value == "") {
                    query = """ 
  query{
  Page(page:1,perPage:100){
    media(sort:POPULARITY){
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
                    query = """ 
  query{
  Page(page:1,perPage:100){
    media(sort:POPULARITY,search:"$value"){
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
                final animeMediaList = result.data?['Page']['media'];
                return GridView.builder(
                  physics: ScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
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
                    print(animeMediaList[index]);
                    return Container(
                      child: Column(
                        children: [
                          Image.network(
                              animeMediaList[index]['coverImage']['medium']),
                          Text(
                            animeTitle,
                            overflow: TextOverflow.visible,
                          )
                        ],
                      ),
                    );
                  }),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
