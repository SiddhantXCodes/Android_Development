import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(QuotesApp());
}

class QuotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: QuotesList()),
    );
  }
}

class QuotesList extends StatefulWidget {
  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> quotes = [
    {
      "quote": "Believe you can and you're halfway there.",
      "author": "Theodore Roosevelt",
    },
    {
      "quote": "Push yourself, because no one else is going to do it for you.",
      "author": "Unknown",
    },
    {
      "quote": "Success doesn’t just find you. You have to go out and get it.",
      "author": "Unknown",
    },
    {
      "quote": "Great things never come from comfort zones.",
      "author": "Anonymous",
    },
    {"quote": "Dream it. Wish it. Do it.", "author": "Unknown"},
    {"quote": "Don’t stop until you’re proud.", "author": "Unknown"},
    {
      "quote":
          "The harder you work for something, the greater you’ll feel when you achieve it.",
      "author": "Unknown",
    },
  ];

  int currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  void nextQuote() {
    setState(() {
      currentIndex = Random().nextInt(quotes.length);
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuote = quotes[currentIndex];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF141E30), Color(0xFF243B55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Motivational Quotes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '"${currentQuote['quote']}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "- ${currentQuote['author']}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: nextQuote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 92, 160, 189),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Next Quote",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
