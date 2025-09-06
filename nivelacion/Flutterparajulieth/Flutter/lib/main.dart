import 'package:el_escondite_animal/ui/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main (){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Super sena",
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}