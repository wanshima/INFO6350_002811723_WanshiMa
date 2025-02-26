import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  Map<int, List<String>> _selectedAnswers = {};
  Timer? _timer;
  int _timeLeft = 60;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  void _loadQuestions() async {
    List<Question> loadedQuestions = await QuestionService.loadQuestions();
    loadedQuestions.shuffle(); // Randomize question order
    setState(() {
      _questions = loadedQuestions;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endQuiz();
      }
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      if (!_selectedAnswers.containsKey(_currentQuestionIndex)) {
        _selectedAnswers[_currentQuestionIndex] = [];
      }
      _selectedAnswers[_currentQuestionIndex]!.add(answer);
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _endQuiz();
    }
  }

  void _endQuiz() {
    _timer?.cancel();
    _calculateScore();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(score: _score)),
    );
  }

  void _calculateScore() {
    _score = 0;
    for (int i = 0; i < _questions.length; i++) {
      final correctAnswers = _questions[i].correct;
      final userAnswers = _selectedAnswers[i] ?? [];
      if (Set.from(userAnswers).containsAll(correctAnswers) &&
          Set.from(correctAnswers).containsAll(userAnswers)) {
        _score++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Question currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz App"), actions: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text("⏳ $_timeLeft sec"),
        ),
      ]),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(currentQuestion.question, style: TextStyle(fontSize: 18)),
          ),
          ...currentQuestion.options.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: _selectedAnswers[_currentQuestionIndex]?.contains(option) ?? false,
              onChanged: (selected) {
                if (currentQuestion.type == "multiple_select") {
                  if (selected == true) {
                    _selectAnswer(option);
                  } else {
                    _selectedAnswers[_currentQuestionIndex]?.remove(option);
                  }
                } else {
                  _selectedAnswers[_currentQuestionIndex] = [option];
                }
                setState(() {});
              },
            );
          }).toList(),
          ElevatedButton(onPressed: _nextQuestion, child: Text("Next"))
        ],
      ),
    );
  }
}
