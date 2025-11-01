import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1116),
      ),
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage>
    with SingleTickerProviderStateMixin {
  String input = '';
  String output = '0';
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<String> buttons = [
    'C',
    '⌫',
    '%',
    '/',
    '7',
    '8',
    '9',
    '*',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '00',
    '0',
    '.',
    '=',
  ];

  void playClickSound() async {
    // Optional: Add your own click.mp3 file inside assets/sounds/
    // and declare in pubspec.yaml
    await _audioPlayer.play(AssetSource('sounds/click.mp3'));
  }

  void buttonPressed(String text) {
    playClickSound();
    setState(() {
      if (text == 'C') {
        input = '';
        output = '0';
      } else if (text == '⌫') {
        if (input.isNotEmpty) input = input.substring(0, input.length - 1);
      } else if (text == '=') {
        _evaluate();
      } else {
        input += text;
      }
    });
  }

  void _evaluate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      output = result.toString();
    } catch (e) {
      output = 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Display section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    input,
                    style: const TextStyle(fontSize: 36, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    output,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Buttons at the bottom
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1C1F26), Color(0xFF0E1116)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final button = buttons[index];
                  return PressableButton(
                    text: button,
                    onPressed: () => buttonPressed(button),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PressableButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PressableButton({required this.text, required this.onPressed});

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;

  bool isOperator(String x) =>
      (x == '/' || x == '*' || x == '-' || x == '+' || x == '=' || x == '%');

  @override
  Widget build(BuildContext context) {
    final bool operator = isOperator(widget.text);
    final Color color = operator
        ? const Color(0xFF00C4FF)
        : const Color(0xFF1F2937);

    return Listener(
      onPointerDown: (_) => setState(() => _isPressed = true),
      onPointerUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Transform.translate(
          offset: _isPressed ? const Offset(2, 2) : Offset.zero,
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: operator ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
