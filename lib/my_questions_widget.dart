import 'package:flutter/material.dart';
import 'package:admin_side_app/questioner_view_widget.dart';

class MyQuestions extends StatefulWidget{
  late String token;
  final List<dynamic> questions;
  final bool adminView;
  final Function(String) updateToken;

  MyQuestions({required this.token, required this.questions, required this.adminView, required this.updateToken});
  _MyQuestionsState createState()=> _MyQuestionsState();
}

class _MyQuestionsState extends State<MyQuestions> {

  late String token;
  late List<dynamic> questions;
  late bool adminView;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    questions = widget.questions;
    adminView = widget.adminView;
  }

  void _updateToken(newToken){
    token = newToken;
    widget.updateToken(newToken);
  }

  void updateQuestions(question, index){
    setState(() {
      questions[index] = question;
    });
    print("update questions ran");
  }

  void pushWidgetAgain(res, index) async{
    if(res!=null && res=="updated") {
      final res_ = await Navigator.push(context,
          MaterialPageRoute(
              builder: (context) =>
                  QuestionerViewWidget(
                    questionPaper: questions[index],
                    token: token,
                    adminView: adminView,
                    updateToken: _updateToken,
                    updateQuestionPaper: (question) {
                      updateQuestions(question, index);
                    },
                  )
          )
      );
      pushWidgetAgain(res_, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Questions'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (BuildContext context, int index) {
          final question = questions[index];
          final name = question['name'] as String;
          final type = question['type'] as String;

          return InkWell(
            onTap: () async {
              String? res = await Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => QuestionerViewWidget(
                        questionPaper: questions[index],
                        token: token,
                        adminView: adminView,
                        updateToken: _updateToken,
                        updateQuestionPaper: (question){
                          updateQuestions(question, index);
                        },
                      )
                  )
              );
              // Do something with the updated token, like update state.
              pushWidgetAgain(res, index);
            },
            child: Card(
              child: ListTile(
                title: Text(name),
                subtitle: Text(type),
              ),
            ),
          );
        },
      ),
    );
  }
}
