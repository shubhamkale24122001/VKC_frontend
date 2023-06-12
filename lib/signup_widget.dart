import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:admin_side_app/loading_widget.dart';
import "package:admin_side_app/constants.dart";

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up Page'),
      ),
      body: _isLoading
          ? LoadingWidget()
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _firstName = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _lastName = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Sign Up'),
                ),
                SizedBox(height: 16.0),
                Text(_message, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        print("sending post request");
        Constants consts = Constants();
        final url = Uri.parse('${consts.domain}/api/authentication/signup');
        final headers = {'Content-Type': 'application/json'};
        final json_ = {
          'firstname': _firstName,
          'lastname': _lastName,
          'username': _username,
          'password': _password,
          'isAdmin': 'true',
        };
        print(json_);
        final response = await http.post(url, headers: headers, body:jsonEncode(json_));
        // final responseData = json.decode(response.body);
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final success = responseData['success'] as bool;
        if (success) {
          Navigator.pop(context);
        } else {
          setState(() {
            _message = responseData['message'];
            _isLoading = false;
          });
        }
      } catch (error) {
        setState(() {
          _message = 'Error occurred: $error';
          _isLoading = false;
        });
      }
    }
  }
}

