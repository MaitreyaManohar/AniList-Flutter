import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CharacterList extends StatelessWidget {
  String animeTitle = " ";
  String query = "";
  CharacterList({super.key, required this.animeTitle}) {
    query = """
query{
  Media(search:"${animeTitle.trim()}"){
    characters {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Characters of ${animeTitle.trim()}"),
      ),
    );
  }
}
