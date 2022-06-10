import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

import 'package:whatnext_flutter_client/interfaces/interfaces.dart';

import '../models/models.dart';
import '../views/image_banner.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchTerm = "";
  Timer? _debounce;
  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();
  final List<SearchResult> _searchResults = [];

  @override
  Widget build(BuildContext contex) {
    return Padding(
        padding: const EdgeInsets.all(25),
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(
                      "Új sorozat hozzáadása",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextFormField(
                        decoration:
                            const InputDecoration(hintText: "Keresés..."),
                        onChanged: _onSearchChanged),
                    const SizedBox(height: 15),
                    Expanded(
                        child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) => ListTile(
                          title: Text(_searchResults[index].name),
                          leading: ImageBanner(_searchResults[index].banner),
                          onTap: () {
                            print('Add show: ${_searchResults[index].id}');
                          }),
                    ))
                  ],
                ))));
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      var result = await _client.search(query);
      setState(() {
        _searchResults.clear();
        _searchResults.addAll(result);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
