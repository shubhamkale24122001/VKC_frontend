import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PermissionsChange extends StatefulWidget {
  final String token;
  final List<dynamic> referenceList;
  final String? urlAdd;
  final String? urlRemove;
  final String title;
  final Function(String) updateToken;

  PermissionsChange({
    required this.token,
    required this.referenceList,
    this.urlAdd,
    this.urlRemove,
    required this.title,
    required this.updateToken
  });

  @override
  _PermissionsChangeState createState() => _PermissionsChangeState();
}

class _PermissionsChangeState extends State<PermissionsChange> {
  TextEditingController _textEditingController = TextEditingController();
  List<dynamic> _selectedList = [];
  late String _currentToken;

  @override
  void initState() {
    super.initState();
    _currentToken = widget.token;
  }

  void _updateToken(String newToken) {
    setState(() {
      _currentToken = newToken;
      widget.updateToken(newToken);
    });
  }

  List<String> _getSuggestions(String query) {
    List<String> suggestions = [];
    for (var map in widget.referenceList) {
      String name = map['name']!;
      if (name.toLowerCase().startsWith(query.toLowerCase())) {
        suggestions.add(name);
      }
    }
    return suggestions;
  }

  void _addSelected(String name) {
    for (var map in widget.referenceList) {
      if (map['name'] == name) {
        setState(() {
          _selectedList.add(map);
        });
        return;
      }
    }
    setState(() {
      _selectedList.add({"name":name, "id": name});
    });
  }

  void _removeSelected(Map<String, String> map) {
    setState(() {
      _selectedList.remove(map);
    });
  }

  Future<void> _handleSubmit(String action) async {
    final body =  _selectedList.map((mapObj)=>mapObj["id"]).toList();
    try {
      String url = action == 'add' ? widget.urlAdd! : widget.urlRemove!;
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'authorization': 'Bearer ${_currentToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (data["success"]) {
        _updateToken(data["token"]);
        Navigator.pop(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('${data["message"] != null ? data["message"] : "Error Occured"}'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title),
              SizedBox(height: 8),
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _addSelected(_textEditingController.text);
                      _textEditingController.clear();
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              if (_textEditingController.text.isNotEmpty) ...[
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _getSuggestions(_textEditingController.text).length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_getSuggestions(_textEditingController.text)[index]),
                      onTap: () {
                        _addSelected(_getSuggestions(_textEditingController.text)[index]);
                        _textEditingController.clear();
                      },
                    );
                  },
                ),
              ],
              if (_selectedList.isNotEmpty) ...[
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var selected in _selectedList) ...[
                      Chip(
                        label: Text(selected["name"]!),
                        onDeleted: () {
                          _removeSelected(selected);
                        },
                      ),
                    ],
                  ],
                ),
              ],
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if(widget.urlAdd != null)
                  ElevatedButton(
                    onPressed:()=> _handleSubmit("add"),
                    child: Text('Add'),
                  ),
                  if(widget.urlRemove!=null)
                  ElevatedButton(
                    onPressed:()=> _handleSubmit('remove'),
                    child: Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
