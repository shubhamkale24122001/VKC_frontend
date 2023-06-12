import 'package:flutter/material.dart';

class QuestionView extends StatefulWidget {
  final String question;
  final String answerType;
  final List<String> possibleAnswers;
  List<String> selectedAnswers = [];

  QuestionView({
    required this.question,
    required this.answerType,
    required this.possibleAnswers,
  });

  @override
  _QuestionViewState createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  // List<String> _selectedAnswers = [];

  void _onAnswerSelected(String value) {
    setState(() {
      if (widget.selectedAnswers.contains(value)) {
        widget.selectedAnswers.remove(value);
      } else {
        widget.selectedAnswers.add(value);
      }
    });
  }

  Widget _buildPossibleAnswers() {
    switch (widget.answerType) {
      case 'paragraph':
        return TextField(
          maxLines: null,
          onChanged: (value) {
            widget.selectedAnswers.clear();
            widget.selectedAnswers.add(value);
          },
          decoration: InputDecoration(
            hintText: 'Enter your answer',
          ),
        );
      case 'multiple_choice_single_correct':
        return Column(
          children: widget.possibleAnswers
              .map(
                (answer) => RadioListTile(
              title: Text(answer),
              value: answer,
              groupValue: widget.selectedAnswers.isEmpty ? null : widget.selectedAnswers[0],
              onChanged: (_)=>_onAnswerSelected(answer),
            ),
          )
              .toList(),
        );
      case 'multiple_choice_multiple_correct':
        return Column(
          children: widget.possibleAnswers
              .map(
                (answer) => CheckboxListTile(
              title: Text(answer),
              value: widget.selectedAnswers.contains(answer),
              onChanged: (_) => _onAnswerSelected(answer),
            ),
          )
              .toList(),
        );
      default:
        return Text('Unsupported answer type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question: ${widget.question}'),
        SizedBox(height: 10),
        // Text('Possible Answers:'),
        SizedBox(height: 10),
        _buildPossibleAnswers(),
        SizedBox(height: 10),
      ],
    );
  }
}
