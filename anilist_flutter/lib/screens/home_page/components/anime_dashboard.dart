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
  Page(page:2,perPage:100){
    media(sort:POPULARITY){
      
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
  Page(page:2,perPage:100){
    media(sort:POPULARITY){
      
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
  Page(page:2,perPage:100){
    media(sort:POPULARITY,search:"$value"){
      
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
                    borderSide: BorderSide.none),
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
                final _animeMediaList = result.data?['Page']['media'];
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _animeMediaList.length,
                  itemBuilder: ((context, index) {
                    final _animeNamesEnglish =
                        _animeMediaList[index]['title']['english'];
                    final _animeNamesNative =
                        _animeMediaList[index]['title']['native'];

                    if (_animeNamesEnglish != null) {
                      return Text(_animeNamesEnglish);
                    } else if (_animeNamesNative != null) {
                      return Text(_animeNamesNative);
                    } else {
                      print(_animeMediaList[index]['title']);
                      return const Text("NONE");
                    }
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
