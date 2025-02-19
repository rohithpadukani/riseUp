import 'package:flutter/material.dart';

class QuotesPage extends StatefulWidget {
  QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Checkbox(
          value: isCompleted,
          onChanged: (bool? value){
            setState(() {
              isCompleted = value!;
            });
            
          },
          
        ),
      ),
    );
  }
}