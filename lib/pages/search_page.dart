import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import 'package:whatnext/_lib.dart';

class SearchPage extends StatefulWidget {
  const SearchPage(this._groupId, {super.key});
  final int _groupId;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _error = "";
  Timer? _debounce;
  final WhatNextClient _client = GetIt.I.get<WhatNextClient>();
  final List<SearchResult> _searchResults = [];

  @override
  Widget build(BuildContext contex) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
            decoration: const InputDecoration(hintText: "Keresés..."),
            onChanged: _onSearchChanged),
        const SizedBox(height: 3),
        Text(_error, style: ApplicationTheme.errorTextTheme),
        const SizedBox(height: 3),
        Expanded(
            child: SizedBox(
                width: 300,
                height: 330,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) => ListTile(
                      title: Text(_searchResults[index].name),
                      leading: ImageBanner(_searchResults[index].banner),
                      onTap: () async {
                        var result = await _client.addShow(
                            _searchResults[index].id, widget._groupId);
                        if (result.isNotEmpty && result != '1') {
                          setState(() {
                            _error = result;
                          });
                        } else {
                          if (!mounted) return;
                          Navigator.pop(context, true);
                        }
                      }),
                )))
      ],
    );
  }

  void _onSearchChanged(String query) {
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
