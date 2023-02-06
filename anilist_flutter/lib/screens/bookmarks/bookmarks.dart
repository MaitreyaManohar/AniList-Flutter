import 'package:anilist_flutter/screens/home_page/components/animeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../assets/colors.dart';
import '../../components/side_bar.dart';

class BookMarks extends StatelessWidget {
  const BookMarks({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideBar(),
      appBar: AppBar(
        backgroundColor: MyColors.backgroundColor,
        centerTitle: true,
        title: const Text("My Bookmarks"),
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
            if (bookmarks.isEmpty) {
              return const Center(
                child: Text("You have no bookmarks"),
              );
            }
            return ListView.builder(
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                return Text(bookmarks[index]);
              },
            );
          } else {
            return const Text("Loading");
          }
        },
      ),
    );
  }
}
