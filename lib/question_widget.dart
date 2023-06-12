import 'package:flutter/material.dart';

class QuestionWidget extends StatefulWidget {
  String? selectedAnswerType = 'paragraph';
  List<String> possibleAnswers = [];
  TextEditingController questionController = TextEditingController();
  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  // String? _selectedAnswerType = 'paragraph';
  // List<String> _possibleAnswers = [];
  // TextEditingController _questionController = TextEditingController();

  void _onAnswerTypeSelected(String? value) {
    setState(() {
      widget.selectedAnswerType = value;
    });
  }

  void _addPossibleAnswer() {
    setState(() {
      widget.possibleAnswers.add('');
    });
  }

  void _removePossibleAnswer(int index) {
    setState(() {
      widget.possibleAnswers.removeAt(index);
    });
  }

  void _updatePossibleAnswer(int index, String value) {
    // setState(() {
    //   widget.possibleAnswers[index] = value;
    // });
    widget.possibleAnswers[index] = value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question'),
        TextField(
          controller: widget.questionController,
        ),
        SizedBox(height: 10),
        Text('Answer Type'),
        DropdownButton<String>(
          value: widget.selectedAnswerType,
          items: <List<String>>[['paragraph', 'Paragraph'], ['multiple_choice_single_correct', 'Multiple Choice - Single Option Correct'], ["multiple_choice_multiple_correct",'Multiple Choice - Multiple Option Correct']].map((List<String> value) {
            return DropdownMenuItem<String>(
              value: value[0],
              child: Text(value[1]),
            );
          }).toList(),
          onChanged: _onAnswerTypeSelected,
        ),
        if (widget.selectedAnswerType != 'paragraph') ...[
          SizedBox(height: 10),
          Text('Possible Answers'),
          for (int i = 0; i < widget.possibleAnswers.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: widget.possibleAnswers[i]),
                    onChanged: (value) => _updatePossibleAnswer(i, value),
                    decoration: InputDecoration(
                      hintText: 'Enter possible answer',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => _removePossibleAnswer(i),
                ),
              ],
            ),
          ],
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Add Possible Answer'),
            onPressed: _addPossibleAnswer,
          ),
        ],
      ],
    );
  }
}
