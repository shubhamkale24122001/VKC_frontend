import 'package:flutter/material.dart';
import 'package:admin_side_app/quiz_question_widget.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:admin_side_app/constants.dart";

class QuizWidget extends StatefulWidget {
  final String token;
  String? name;
  bool? editAnswer;
  bool? multipleAttempts;
  List<dynamic>? questions;
  String? url;
  final Function(String) updateToken;
  Function(Map<String,dynamic>)? updateQuestion;

  QuizWidget({required this.token, required this.updateToken, this.name, this.editAnswer, this.multipleAttempts, this.questions, this.url, this.updateQuestion});
  @override
  _QuizWidgetState createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  String _quizName = '';
  bool _editAnswer = false;
  bool _multipleAttempts = false;
  List<QuizQuestionWidget> _questionWidgets = [];
  late String _currentToken;

  void initState() {
    super.initState();
    _currentToken = widget.token;
    _quizName = widget.name ?? _quizName;
    _editAnswer = widget.editAnswer ?? _editAnswer;
    _multipleAttempts = widget.multipleAttempts ?? _multipleAttempts;
    if(widget.questions != null){
      List<dynamic> tmp_questions = widget.questions!.map((question){


        QuizQuestionWidget ques =  QuizQuestionWidget();
        ques.questionController.text = question["question"];
        ques.selectedAnswerType = question["type"];

        List<String> tmp=[];
        for(dynamic ele in question["possibleAnswers"]){
          tmp.add(ele as String);
        }
        ques.possibleAnswers = tmp;

        tmp=[];
        for(dynamic ele in question["correctAnswers"]){
          tmp.add(ele as String);
        }
        ques.correctAnswers = tmp;

        return ques;
      }).toList();

      for(dynamic ele in tmp_questions){
        _questionWidgets.add(ele as QuizQuestionWidget);
      }
    }
  }

  void _updateToken(String newToken) {
    setState(() {
      _currentToken = newToken;
      widget.updateToken(newToken);
    });
  }

  void _addQuestionWidget() {
    setState(() {
      _questionWidgets.add(QuizQuestionWidget());
    });
  }

  void _removeQuestionWidget(QuizQuestionWidget questionWidget) {
    setState(() {
      _questionWidgets.remove(questionWidget);
    });
  }

  Future<void> _submitQuestion() async{
    Constants consts = Constants();
    List<Map<dynamic,dynamic>> questions = _questionWidgets.map((QuizQuestionWidget ques){
      return {
        "type": ques.selectedAnswerType,
        "possibleAnswers": ques.possibleAnswers,
        "question": ques.questionController.text,
        "correctAnswers": ques.correctAnswers
      };
    }).toList();
    final url = widget.url==null ? Uri.parse('${consts.domain}/survey/question') : Uri.parse(widget.url!) ;
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': 'Bearer ${widget.token}',
    };
    final body =<String, dynamic>{
      'name': _quizName,
      'type': 'quiz',
      'questions': questions,
      'multipleAttempts': _multipleAttempts,
      'editAnswer': _editAnswer
    };
    // Add post request here
    try{
      final response = widget.url==null ?
      await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ):
      await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
      ;


      final data = jsonDecode(response.body);
      if (data["success"]) {
        final updatedToken = data['token'];
        _updateToken(updatedToken);
        if(widget.url!=null && widget.updateQuestion!=null){
          widget.updateQuestion!(data["question"]);
          Navigator.pop(context,"updated");
        }
        else {
          Navigator.pop(context);
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text('${data["message"] == null ? data["message"] : "Error Occured"}'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Widget'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: TextEditingController(text: _quizName),
              decoration: InputDecoration(
                labelText: 'Quiz Name',
              ),
              onChanged: (value) {
                // setState(() {
                //   _quizName = value;
                // });
                _quizName = value;
              },
            ),
            SwitchListTile(
              title: Text('Edit Answer'),
              value: _editAnswer,
              onChanged: (bool value) {
                setState(() {
                  _editAnswer = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Multiple Attempts'),
              value: _multipleAttempts,
              onChanged: (bool value) {
                setState(() {
                  _multipleAttempts = value;
                });
              },
            ),
            ..._questionWidgets.map(
                  (questionWidget) => Column(
                children: [
                  questionWidget,
                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text('Remove Question'),
                    onPressed: () => _removeQuestionWidget(questionWidget),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Add Question'),
              onPressed: _addQuestionWidget,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: _submitQuestion,
            ),
          ],
        ),
      ),
    );
  }
}
