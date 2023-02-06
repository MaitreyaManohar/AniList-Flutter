import 'package:anilist_flutter/screens/home_page/components/animeCard.dart';
import 'package:anilist_flutter/screens/log_in/log_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart' as lib2;
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../assets/colors.dart';
import '../../components/side_bar.dart';

class BookMarks extends StatelessWidget {
  const BookMarks({super.key});
  void loading(BuildContext context) {
    //Loading Progress indicator
    showDialog(
        context: context,
        builder: ((context) => const Center(
              child: CircularProgressIndicator(),
            )));
  }

  final String query = """query Bookmarks(\$id: Int!){
  Media(id:\$id){
    id
    title{
      romaji
      english
    }
    
    coverImage{
      medium
    }
  }
  
}""";

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: ValueNotifier<GraphQLClient>(
        GraphQLClient(
          link: HttpLink("https://graphql.anilist.co/"),
          cache: GraphQLCache(
            store: HiveStore(),
          ),
        ),
      ),
      child: Scaffold(
        drawer: const SideBar(),
        appBar: AppBar(
          backgroundColor: MyColors.backgroundColor,
          centerTitle: true,
          title: const Text("My Bookmarks"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.transparent),
              onPressed: () async {
                loading(context);
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: ((context) => LogIn())));
              },
              child: const Text(
                'SignOut',
              ),
            )
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }
            if (snapshot.hasData) {
              List bookmarks = (snapshot.data!.data()!['bookmarks'] ?? []);
              print(bookmarks);
              if (bookmarks.isEmpty) {
                return const Center(
                  child: Text("You have no bookmarks"),
                );
              }
              return ListView.builder(
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  return lib2.Query(
                    builder: (result, {fetchMore, refetch}) {
                      if (result.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return AnimeCard(
                          image: result.data?['Media']['coverImage']['medium'],
                          title: (result.data?['Media']['title']['english']==null)? result.data!['Media']['title']['romaji'] : result.data?['Media']['title']['english'],
                          id: result.data?['Media']['id']);
                    },
                    options: lib2.QueryOptions(
                      document: gql(query),
                      variables: {'id': bookmarks[index]},
                    ),
                  );
                },
              );
            } else {
              return const Text("Loading");
            }
          },
        ),
      ),
    );
  }
}
