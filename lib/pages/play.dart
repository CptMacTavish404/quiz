import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Question {
  final String question;
  final List<String> answers;
  final String correctAnswer;

  Question({required this.question, required this.answers, required this.correctAnswer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctAnswer: json['correctAnswer'],
    );
  }
}

class Play extends StatefulWidget {
  const Play({super.key});

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  Future<List<Question>>? _questionsFuture;
  int _currentQuestionIndex = 0;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  Future<List<Question>> _loadQuestions() async {
    final jsonString = await rootBundle.loadString('assets/questions.json');
    final jsonMap = jsonDecode(jsonString) as List;
    final List<Question> questions = jsonMap.map((json) => Question.fromJson(json)).toList();
    return questions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Question> questions = snapshot.data!;
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    questions[_currentQuestionIndex].question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: questions[_currentQuestionIndex].answers.map((answer) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (answer == questions[_currentQuestionIndex].correctAnswer) {
                                setState(() {
                                  _result = 'Correct Answer!';
                                });
                              } else {
                                setState(() {
                                  _result = 'Incorrect Answer!';
                                });
                              }
                              Future.delayed(const Duration(milliseconds: 1000), () {
                                setState(() {
                                  _result = '';
                                  _currentQuestionIndex = (_currentQuestionIndex + 1) % questions.length;
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.indigoAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              answer,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex = (_currentQuestionIndex - 1) % questions.length;
                          });
                        },
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentQuestionIndex = (_currentQuestionIndex + 1) % questions.length;
                          });
                        },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}