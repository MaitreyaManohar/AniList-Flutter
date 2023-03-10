import 'package:anilist_flutter/screens/anime_details/anime_details.dart';
import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final String image;
  final String title;
  final int id;
  const AnimeCard({super.key, required this.image, required this.title,required this.id});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AnimeDetails(
                        title: title.replaceAll('"', ''),
                        id: id
                      ))));
        },
        child: Card(
          margin: const EdgeInsets.all(10),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: Image.network(image, height: 200, fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    overflow: TextOverflow.visible,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
