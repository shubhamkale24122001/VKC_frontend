import 'package:flutter/material.dart';
import 'package:admin_side_app/questioner_view_widget.dart';
import "package:admin_side_app/change_permissions_widget.dart";
import 'package:admin_side_app/constants.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupView extends StatefulWidget {
  final Map<String, dynamic> group;
  final String token;
  final Function(String) updateToken;
  final bool adminView;

  GroupView({required this.group,required this.token, required this.updateToken, required this.adminView});

  @override
  _GroupViewState createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  late List<dynamic> questions;
  List<dynamic> _selectedQuestions=[];
  bool _isLoading = true;
  bool _removing = false;
  late String _currentToken;

  @override
  void initState(){
    super.initState();
    _currentToken = widget.token;
    fetchQuestions();
  }

  void fetchQuestions() async {
    try{
      Constants consts = Constants();
      print(widget.group);
      final response = await http.get(
          Uri.parse(
              '${consts.domain}/survey/group/${widget.group["_id"]}/questions'),
          headers: {"Content-Type": "application/json",'authorization': 'Bearer $_currentToken'});

      final data = json.decode(response.body);
      if (data["success"]) {
        setState(() {
          questions = data["questions"];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    }catch(e){
      print(e);
    }
  }


void _updateToken(String newToken) {
    setState(() {
      _currentToken = newToken;
      widget.updateToken(newToken);
    });
  }

  void addQuestions() async{
    try{
      Constants consts = Constants();
      final url = '${consts.domain}/survey/question/userAdminQuestions';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $_currentToken'
        },
      );

      final data = json.decode(response.body);
      List<dynamic> referenceList = [];
      print(data);
      if (data["success"]) {
        referenceList = data["questions"].map((question)=>{"name": question["name"], "id": question["_id"]}).toList();
      } else {
        throw Exception('Failed to load reference questions');
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PermissionsChange(
            token: _currentToken,
            referenceList: referenceList,
            urlAdd:
                '${consts.domain}/survey/group/${widget.group["_id"]}/addQuestions',
            title: 'Add or Remove User Access',
            updateToken: _updateToken,
          );
        },
      );
    }
    catch(e){
      print(e);
    }
    fetchQuestions();
  }

  void removeQuestions(){
    final removedQuestions = <dynamic>[];
    for(int i=0; i<_selectedQuestions.length; i++){
      questions.remove(_selectedQuestions[i]);
      removedQuestions.add(_selectedQuestions[i]);
    }
    _selectedQuestions.clear();

    Constants consts = Constants();
    final url = '${consts.domain}/survey/group/${widget.group["_id"]}/removeQuestions';
    http.put(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'authorization': 'Bearer $_currentToken'},
        body: jsonEncode(removedQuestions.map((question)=> question["_id"]).toList())
    ).then((response) {
      final data = jsonDecode(response.body);
      if(data["success"]) {
        _updateToken(data["token"]);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Questions removed successfully'))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove questions'))
        );
      }
      setState(() {
        _isLoading = false;
        _removing = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove questions'))
      );
      setState(() {
        _isLoading = false;
        _removing = false;
      });
    });
  }

  void _navigateToPermissionsChangeWidget() async{
    Constants consts = Constants();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PermissionsChange(
          token: _currentToken,
          referenceList: widget.group["validUsers"].map((user)=>{"name":user, "id": user }).toList(),
          urlAdd: '${consts.domain}/permissions/modify/give/access/group/${widget.group["_id"]}',
          urlRemove: '${consts.domain}/permissions/modify/remove/access/group/${widget.group["_id"]}',
          title: 'Add or Remove User Access',
          updateToken: _updateToken,
        );
      },
    );
  }

  void _navigateToAdminPermissionsChangeWidget() async{
    Constants consts = Constants();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PermissionsChange(
          token: _currentToken,
          referenceList: widget.group["adminAccessUsers"].map((user)=>{"name":user, "id": user }).toList(),
          urlAdd: '${consts.domain}/permissions/modify/give/adminAccess/group/${widget.group["_id"]}',
          urlRemove: '${consts.domain}/permissions/modify/remove/adminAccess/group/${widget.group["_id"]}',
          title: 'Add or Remove User Admin Access',
          updateToken: _updateToken,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group["name"]),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : 
      Column(
        children: [
          if(widget.adminView && !_removing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to questionerWidget or quizWidget
                    addQuestions();

                  },
                  child: Text('Add Question'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to questionerWidget or quizWidget
                    setState(() {
                      _removing = true;
                    });
                  },
                  child: Text('Remove Question'),
                ),
              ],
            ),
          if(widget.adminView && !_removing)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to permissionsChangeWidget for edit access
                    _navigateToPermissionsChangeWidget();
                  },
                  child: Text('Edit Access'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to permissionsChangeWidget for edit admin access
                    _navigateToAdminPermissionsChangeWidget();
                  },
                  child: Text('Edit Admin Access'),
                ),
              ],
            ),
          if(_removing)
            ElevatedButton(
              onPressed: () {
                // Remove selected questions and update server
                setState(() {
                  _isLoading = true;
                });
                removeQuestions();
              },
              child: Text('Confirm Removal'),
            ),
          Expanded(
            child:ListView.builder(
              itemCount: questions.length,
              itemBuilder: (BuildContext context, int index) {
                final question = questions[index];
                final name = question['name'] as String;
                final type = question['type'] as String;

                if(_removing){
                  return CheckboxListTile(
                    value: _selectedQuestions.contains(question),
                    onChanged: (selected) {
                      setState(() {
                        if(selected != null && selected) {
                          _selectedQuestions.add(question);
                        } else {
                          _selectedQuestions.remove(question);
                        }
                      });
                    },
                    title: Text(name),
                    subtitle: Text(type),
                  );
                }
                else {
                        return InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QuestionerViewWidget(
                                          questionPaper: questions[index],
                                          token: _currentToken,
                                          adminView: false,
                                          updateToken: _updateToken,
                                          groupId: widget.group["_id"]
                                        )));
                            // Do something with the updated token, like update state.
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text(type),
                            ),
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
