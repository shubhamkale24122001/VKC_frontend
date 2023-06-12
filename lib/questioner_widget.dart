import 'package:flutter/material.dart';
import 'package:admin_side_app/question_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:admin_side_app/constants.dart";

class QuestionerWidget extends StatefulWidget {
  final String token;
  String? name;
  bool? editAnswer;
  bool? multipleAttempts;
  List<dynamic>? questions;
  String? url;
  final Function(String) updateToken;
  Function(Map<String,dynamic>)? updateQuestion;

  QuestionerWidget({required this.token, required this.updateToken, this.name, this.editAnswer, this.multipleAttempts, this.questions, this.url,  this.updateQuestion});
  @override
  _QuestionerWidgetState createState() => _QuestionerWidgetState();
}
class _QuestionerWidgetState extends State<QuestionerWidget> {
  String _questionerName = '';
  bool _editAnswer = false;
  bool _multipleAttempts = false;
  List<QuestionWidget> _questionWidgets = [];
  late String _currentToken;

  @override
  void initState() {
    super.initState();
    _currentToken = widget.token;
    _questionerName = widget.name ?? _questionerName;
    _editAnswer = widget.editAnswer ?? _editAnswer;
    _multipleAttempts = widget.multipleAttempts ?? _multipleAttempts;
    if(widget.questions != null){
      List<dynamic> tmp_questions = widget.questions!.map((question){
        List<String> tmp=[];
        for(dynamic ele in question["possibleAnswers"]){
          tmp.add(ele as String);
        }

        QuestionWidget ques =  QuestionWidget();
        ques.questionController.text = question["question"];
        ques.selectedAnswerType = question["type"];
        ques.possibleAnswers = tmp;
        return ques;
      }).toList();

      for(dynamic ele in tmp_questions){
        _questionWidgets.add(ele as QuestionWidget);
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
      _questionWidgets.add(QuestionWidget());
    });
  }

  void _removeQuestionWidget(QuestionWidget questionWidget) {
    setState(() {
      _questionWidgets.remove(questionWidget);
    });
  }

  Future<void> _submitQuestion() async{
    Constants consts = Constants();
    List<Map<dynamic,dynamic>> questions = _questionWidgets.map((QuestionWidget ques){
      return {
        "type": ques.selectedAnswerType,
        "possibleAnswers": ques.possibleAnswers,
        "question": ques.questionController.text
      };
    }).toList();
    final url = widget.url == null ? Uri.parse('${consts.domain}/survey/question'): Uri.parse(widget.url!);
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'authorization': 'Bearer ${_currentToken}',
    };
    final body =<String, dynamic>{
      'name': _questionerName,
      'type': 'questionnaire',
      'questions': questions,
      'multipleAttempts': _multipleAttempts,
      'editAnswer': _editAnswer
    };
    // Add post request here
    try{
      final response = widget.url == null ?
      await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
      :
      await http.put(
        url,
        headers: headers,
        body: jsonEncode(body)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questioner Widget'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: TextEditingController(text: _questionerName),
              decoration: InputDecoration(
                labelText: 'Questioner Name',
              ),
              onChanged: (value) {
                // setState(() {
                //   _questionerName = value;
                // });
                _questionerName=value;
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
