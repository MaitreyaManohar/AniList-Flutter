import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CharacterList extends StatefulWidget {
  String animeTitle = " ";
  CharacterList({super.key, required this.animeTitle});

  @override
  State<CharacterList> createState() => _CharacterListState();
}

class _CharacterListState extends State<CharacterList> {
  String query = "";

  @override
  void initState() {
    super.initState();
    query = """
query{
  Media(search:"${widget.animeTitle.trim()}"){
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
        title: Text("Characters of ${widget.animeTitle}"),
      ),
    );
  }
}
