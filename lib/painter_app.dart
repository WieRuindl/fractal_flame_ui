import 'package:flutter/material.dart';

class PainterApp extends StatelessWidget {
  const PainterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47)),
      home: Scaffold(
        // Outer white container with padding
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          color: Colors.white,
          // Inner yellow container
          child: Container(
            color: Colors.yellow,
          ),
        ),
      ),
    );
  }
}