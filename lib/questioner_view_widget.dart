import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:admin_side_app/question_view_widget.dart';
import 'package:admin_side_app/change_permissions_widget.dart';
import 'package:admin_side_app/questioner_widget.dart';
import 'package:admin_side_app/quiz_widget.dart';
import 'package:admin_side_app/constants.dart';

class QuestionerViewWidget extends StatefulWidget {
  final Map<String, dynamic> questionPaper;
  final String token;
  final bool adminView;
  final Function(String) updateToken;
  Function(Map<String, dynamic>)? updateQuestionPaper;
  String? groupId;

  QuestionerViewWidget({required this.questionPaper, required this.token, required this.adminView, required this.updateToken, this.updateQuestionPaper, this.groupId});

  @override
  _QuestionerViewWidgetState createState() => _QuestionerViewWidgetState();
}

class _QuestionerViewWidgetState extends State<QuestionerViewWidget> {
  late List<QuestionView> _questions;
  bool _isLoading = false;
  late String _currentToken;
  // final Function()

  @override
  void initState() {
    super.initState();
    _currentToken = widget.token;
    List<dynamic> tmp_questions = widget.questionPaper["questions"].map((question){
      List<String> tmp=[];
      for(dynamic ele in question["possibleAnswers"]){
        tmp.add(ele as String);
      }
      return QuestionView(
        question: question["question"],
        possibleAnswers: tmp,
        answerType: question["type"],
      );
    }).toList();

    _questions = [];
    for(dynamic ele in tmp_questions){
      _questions.add(ele as QuestionView);
    }
  }

  void _updateToken(String newToken) {
    setState(() {
      _currentToken = newToken;
      widget.updateToken(newToken);
    });
  }

  void _updateQuestionPaper(question){
    if(widget.updateQuestionPaper!=null){
      widget.updateQuestionPaper!(question);
    }
  }

  void _submitAnswers() async {
    setState(() {
      _isLoading = true;
    });
    try{
      Constants consts = Constants();
      print(widget.questionPaper["_id"]);
      final url = Uri.parse('${consts.domain}/survey/answer/${widget.questionPaper["_id"]}/submitAnswers');
      print(url);
      final body = {
        'answers': _questions.map((QuestionView question) => question.selectedAnswers).toList(),
        "questionPaperId": widget.questionPaper["_id"],
        "groupId": widget.groupId
      };
      print(body);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $_currentToken'
        },
        body: jsonEncode(body),
      );

      print("response passed");
      final data = jsonDecode(response.body);
      print(data);
      if (data["success"]) {
        _updateToken(data["token"]);
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answers')),
        );
      }
    }catch(e){
      print(e);
    }
  }

  void _navigateToQuestionerWidget() async{
    Constants consts = Constants();
    String? res = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QuestionerWidget(
        token: _currentToken,
        name: widget.questionPaper["name"],
        editAnswer: widget.questionPaper["editAnswer"],
        multipleAttempts: widget.questionPaper["multipleAttempts"],
        questions: widget.questionPaper["questions"],
        url: '${consts.domain}/survey/question/modify/${widget.questionPaper["_id"]}',
        updateToken: _updateToken,
        updateQuestion: _updateQuestionPaper,
      ),
    ));

    if(res!=null && res=="updated") Navigator.pop(context, "updated");
  }

  void _navigateToQuizWidget() async{
    Constants consts = Constants();
    String? res =  await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QuizWidget(
        token: _currentToken,
        name: widget.questionPaper["name"],
        editAnswer: widget.questionPaper["editAnswer"],
        multipleAttempts: widget.questionPaper["multipleAttempts"],
        questions: widget.questionPaper["questions"],
        url: '${consts.domain}/survey/question/modify/${widget.questionPaper["_id"]}',
        updateToken: _updateToken,
        updateQuestion: _updateQuestionPaper,
      ),
    ));

    if(res!=null && res=="updated") Navigator.pop(context, "updated");
  }

  void _navigateToPermissionsChangeWidget() async{
    Constants consts = Constants();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PermissionsChange(
          token: _currentToken,
          referenceList: widget.questionPaper["validUsers"].map((user)=>{"name":user, "id": user }).toList(),
          urlAdd: '${consts.domain}/permissions/modify/give/access/questionPaper/${widget.questionPaper["_id"]}',
          urlRemove: '${consts.domain}/permissions/modify/remove/access/questionPaper/${widget.questionPaper["_id"]}',
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
          referenceList: widget.questionPaper["adminAccessUsers"].map((user)=>{"name":user, "id": user }).toList(),
          urlAdd: '${consts.domain}/permissions/modify/give/adminAccess/questionPaper/${widget.questionPaper["id"]}',
          urlRemove: '${consts.domain}/permissions/modify/remove/adminAccess/questionPaper/${widget.questionPaper["id"]}',
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
        title: Text('${widget.questionPaper["name"]}'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          :
      Column(
      children: [
          if(widget.adminView)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to questionerWidget or quizWidget
                  widget.questionPaper["type"] == "quiz" ? _navigateToQuizWidget() : _navigateToQuestionerWidget();
                },
                child: Text('Edit'),
              ),
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
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (ctx, index) {
                return Card(child:_questions[index]);
              },
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: _submitAnswers,
          ),
      ],
      ),
    );
  }
}
