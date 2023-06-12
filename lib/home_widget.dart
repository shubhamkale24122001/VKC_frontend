import 'package:flutter/material.dart';
import 'package:admin_side_app/quiz_widget.dart';
import 'package:admin_side_app/questioner_widget.dart';
import 'package:admin_side_app/group_widget.dart';
import 'package:admin_side_app/my_group_widget.dart';
import 'package:admin_side_app/my_questions_widget.dart';
import 'package:admin_side_app/loading_widget.dart';
import 'package:admin_side_app/constants.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  // final Map<String, dynamic> data;
  final String token;
  final String firstname;
  final String lastname;
  final String username;
  HomePage({required this.token, required this.firstname, required this.lastname, required this.username});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _currentToken;
  String? _firstname;
  String? _lastname;
  late String _username;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentToken = widget.token;
    _firstname = widget.firstname;
    _lastname = widget.lastname;
    _username = widget.username;

  }

  void _updateToken(String newToken) {
    setState(() {
      _currentToken = newToken;
      print("Update Token ran from home");
    });
  }

  Future<Map<String,dynamic>> sendRequest(String url, String err, String errText) async{
    try{
      Constants consts = Constants();
      final response = await http.get(
          Uri.parse(url),
          headers: {"Content-Type": "application/json",'authorization': 'Bearer $_currentToken'});

      final data = json.decode(response.body);
      print(data);
      if (data["success"]) {
        return data;
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(err),
            content: Text(errText),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        return {"success": false};
      }
    }catch(e){
      print(e);
      return {"success": false};
    }
    return {"success": false};
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? LoadingWidget(): Scaffold(
      appBar: AppBar(
        title: Text('Admin Terminal'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('$_firstname $_lastname'),
              accountEmail: Text(''),
            ),
            ListTile(
              title: Text('My Groups (Admin)'),
              onTap: () async{
                Constants consts = Constants();
                Map<String,dynamic> data = await sendRequest('${consts.domain}/survey/group/userAdminGroups',"Failed", "Could not get groups");
                if(data["success"]){
                  List<dynamic> groups = data["groups"] ;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyGroup(token: _currentToken, updateToken: _updateToken, adminView: true, groups: groups,)),
                  );
                }
              },
            ),
            ListTile(
              title: Text('My Groups'),
              onTap: () async{
                Constants consts = Constants();
                Map<String,dynamic> data = await sendRequest('${consts.domain}/survey/group/userGroups',"Failed", "Could not get groups");
                if(data["success"]){
                  List<dynamic> groups = data["groups"];
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyGroup(token: _currentToken, updateToken: _updateToken, adminView: false, groups: groups,)),
                  );
                }
              },
            ),
            ListTile(
              title: Text('My Questions (Admin)'),
              onTap: () async{
                Constants consts = Constants();
                Map<String,dynamic> data = await sendRequest('${consts.domain}/survey/question/userAdminQuestions',"Failed", "Could not get questions");
                if(data["success"]){
                  List<dynamic> questions = data["questions"];
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyQuestions(token: _currentToken, updateToken: _updateToken, adminView: true, questions: questions,)),
                  );
                }
              },
            ),
            ListTile(
              title: Text('My Questions'),
              onTap: () async{
                Constants consts = Constants();
                Map<String,dynamic> data = await sendRequest('${consts.domain}/survey/question/userQuestions',"Failed", "Could not get questions");
                if(data["success"]){
                  List<dynamic> questions = data["questions"];
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyQuestions(token: _currentToken, updateToken: _updateToken, adminView: false, questions: questions,)),
                  );
                }
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Make a survey'),
              onPressed: () async{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuestionerWidget(token: _currentToken, updateToken: _updateToken)),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Make a quiz'),
              onPressed: () async{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizWidget(token: _currentToken, updateToken: _updateToken)),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Make a group'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupWidget(token: _currentToken, updateToken: _updateToken,)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
