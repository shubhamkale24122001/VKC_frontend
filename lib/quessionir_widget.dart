import 'package:flutter/material.dart';
import 'package:admin_side_app/question_widget.dart';

class QuessionairWidget extends StatefulWidget {
  @override
  _QuessionairWidgetState createState() => _QuessionairWidgetState();
}

class _QuessionairWidgetState extends State<QuessionairWidget> {
  List<QuestionWidget> _questionWidgets = [];

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
              onPressed: () {
                // Add submit functionality here
              },
            ),
          ],
        ),
      ),
    );
  }
}
