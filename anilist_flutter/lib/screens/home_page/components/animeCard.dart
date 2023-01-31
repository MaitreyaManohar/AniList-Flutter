import 'package:anilist_flutter/screens/anime_details/anime_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AnimeCard extends StatelessWidget {
  final String image;
  final String title;
  const AnimeCard({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          print(title);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => AnimeDetails(
                        title: title,
                      ))));
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 53, 120),
              borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(
                image,
                height: 300,
                fit: BoxFit.contain,
              ),
              Text(
                title,
                overflow: TextOverflow.visible,
              )
            ],
          ),
        ),
      ),
    );
  }
}
