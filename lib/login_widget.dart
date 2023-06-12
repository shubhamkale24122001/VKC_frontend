import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:admin_side_app/home_widget.dart';
import 'package:admin_side_app/signup_widget.dart';
import 'package:admin_side_app/loading_widget.dart';
import "package:admin_side_app/constants.dart";

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _password;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: _isLoading ? LoadingWidget() : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value ?? '';
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value ?? '';
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                ElevatedButton(
                  onPressed: _goToSignUp,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        Constants consts = Constants();
        final response = await http.post(
          Uri.parse('${consts.domain}/api/authentication/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'username': _username,
            'password': _password,
          }),
        );

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final success = data['success'] as bool;

        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                firstname: data["firstname"],
                lastname: data["lastname"],
                username: data["username"],
                token: data["token"],
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Login Failed'),
              content: Text('Invalid username or password. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToSignUp() {
    // Navigate to the sign up page
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
  }
}
