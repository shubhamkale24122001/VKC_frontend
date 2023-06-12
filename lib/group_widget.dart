import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:admin_side_app/constants.dart';

class GroupWidget extends StatefulWidget {
  final String token;
  final Function(String) updateToken;

  const GroupWidget({required this.token, required this.updateToken});

  @override
  _GroupWidgetState createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  final _formKey = GlobalKey<FormState>();

  late String _currentToken;

  String _groupName = '';
  String _place = '';
  String? _ward;
  String? _taluk;
  String _district = '';
  String _state = '';
  String _country = '';

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

  void _createGroup() async {
    if (_formKey.currentState!.validate()) {
      Constants consts = Constants();
      final url = Uri.parse('${consts.domain}/survey/group');
      final headers = {"Content-Type": "application/json",'authorization': 'Bearer ${_currentToken}'};
      final body = jsonEncode({
        'name': _groupName,
        'location':{
          'place': _place,
          'ward': _ward,
          'taluk': _taluk,
          'district': _district,
          'state': _state,
          'country': _country,
        }
      });
      print(body);
      try{
        final response = await http.post(url, headers: headers, body: body);
        final data = jsonDecode(response.body);
        print(data);
        if (data["success"]) {
          final updatedToken = data['token'];
          _updateToken(updatedToken);
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
      }
      catch(e){
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Group Widget'),
        ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Group Name *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a group name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _groupName = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Place *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a place';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _place = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Ward'),
                  onChanged: (value) {
                    setState(() {
                      _ward = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Taluk'),
                  onChanged: (value) {
                    setState(() {
                      _taluk = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'District *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a district';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _district = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'State *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a state';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _state = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Country *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a country';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _country = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _createGroup,
                  child: Text('Create Group'),
                ),
              ],
            )
        ),
      ),
    );
  }
}
