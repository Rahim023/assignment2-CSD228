import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(GlassyCalculatorApp());

class GlassyCalculatorApp extends StatefulWidget {
  @override
  _GlassyCalculatorAppState createState() => _GlassyCalculatorAppState();
}

class _GlassyCalculatorAppState extends State<GlassyCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glassy Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF4F7FF),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Color(0xFF0B1220))),
        cardColor: Colors.white.withOpacity(0.6),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF7C6CFF),
        scaffoldBackgroundColor: const Color(0xFF07101A),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white70)),
        cardColor: Colors.white.withOpacity(0.06),
      ),
      home: CalculatorHome(
        onThemeToggle: (mode) => setState(() => _themeMode = mode),
        themeMode: _themeMode,
      ),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  final Function(ThemeMode) onThemeToggle;
  final ThemeMode themeMode;
  const CalculatorHome({required this.onThemeToggle, required this.themeMode});

  @override
  _CalculatorHomeState createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String display = '0';
  double? previous;
  String? op;
  bool justCalculated = false;

  void numPress(String s) {
    setState(() {
      if (justCalculated) {
        display = (s == '.') ? '0.' : s;
        justCalculated = false;
        return;
      }
      if (display == '0' && s != '.') display = s;
      else if (display.contains('.') && s == '.') return;
      else display += s;
      if (display.length > 18) display = display.substring(0, 18);
    });
  }

  void allClear() {
    setState(() {
      display = '0';
      previous = null;
      op = null;
      justCalculated = false;
    });
  }

  void toggleSign() {
    setState(() {
      if (display.startsWith('-')) display = display.substring(1);
      else if (display != '0') display = '-$display';
    });
  }

  void backspace() {
    setState(() {
      if (justCalculated) {
        allClear();
        return;
      }
      if (display.length <= 1) display = '0';
      else display = display.substring(0, display.length - 1);
    });
  }

  void setOperation(String operation) {
    setState(() {
      if (previous != null && !justCalculated) {
        // chaining operations
        calculate();
      }
      previous = double.tryParse(display) ?? 0;
      op = operation;
      display = '0';
      justCalculated = false;
    });
  }

  void calculate() {
    if (op == null || previous == null) return;
    double current = double.tryParse(display) ?? 0;
    double result = 0;
    if (op == '+') result = previous! + current;
    else if (op == '-') result = previous! - current;
    else if (op == '*') result = previous! * current;
    else if (op == '/') {
      if (current == 0) {
        allClear();
        setState(() => display = 'OVERFLOW');
        return;
      }
      result = previous! / current;
    }

    if (!result.isFinite || result.abs() > 99999999) {
      allClear();
      setState(() => display = 'OVERFLOW');
      return;
    }

    if (result % 1 != 0) result = double.parse(result.toStringAsFixed(8));

    setState(() {
      // Remove trailing .0 for whole numbers
      display = result.toString().endsWith('.0')
          ? result.toString().split('.0')[0]
          : result.toString();
      previous = null;
      op = null;
      justCalculated = true;
    });
  }

  Widget glassCard({required Widget child, double blur = 12, double borderRadius = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              width: 1.5,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white24
                  : Colors.black12,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black54
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget calcButton(String label,
      {Color? bg, Color? fg, double flex = 1, void Function()? onTap}) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: glassCard(
                blur: 8,
                borderRadius: 14,
                child: Container(
                  height: 68,
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: fg ?? Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isWide = media.size.width > 600;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              widget.onThemeToggle(widget.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.themeMode == ThemeMode.dark
                    ? [const Color(0xFF07101A), const Color(0xFF0B1730)]
                    : [const Color(0xFFF4F7FF), const Color(0xFFE9EEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Floating symbols behind the UI
          FloatingSymbols(isDark: widget.themeMode == ThemeMode.dark),
          // Foreground calculator
          SafeArea(
            child: Center(
              child: Container(
                width: isWide ? 420 : media.size.width * 0.92,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.themeMode == ThemeMode.dark ? Colors.white24 : Colors.black26,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    glassCard(
                      blur: 18,
                      borderRadius: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              op != null ? '${previous?.toString() ?? ''} $op' : '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              alignment: Alignment.centerRight,
                              child: Text(
                                display,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: glassCard(
                        blur: 12,
                        borderRadius: 20,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              buildRow(['AC', '⌫', '±', '÷'], ['AC', 'BACK', 'SIGN', '/']),
                              buildRow(['7', '8', '9', '×'], ['7', '8', '9', '*']),
                              buildRow(['4', '5', '6', '-'], ['4', '5', '6', '-']),
                              buildRow(['1', '2', '3', '+'], ['1', '2', '3', '+']),
                              buildRow(['0', '.', '='], ['0', '.', '='], isLast: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(List<String> labels, List<String> actions, {bool isLast = false}) {
    return Expanded(
      flex: isLast ? 2 : 1,
      child: Row(
        children: labels.map((label) {
          final idx = labels.indexOf(label);
          final action = actions.length > idx ? actions[idx] : label;
          if (label == '0') {
            return calcButton(label, flex: 2, onTap: () => numPress('0'));
          } else if (label == 'AC') {
            return calcButton(label, fg: const Color(0xFFB00020), onTap: allClear);
          } else if (label == '⌫') {
            return calcButton(label, onTap: backspace);
          } else if (label == '±') {
            return calcButton(label, onTap: toggleSign);
          } else if (label == '=') {
            return calcButton(label, bg: Colors.green, fg: Colors.white, onTap: calculate);
          } else if (label == '.') {
            return calcButton(label, onTap: () => numPress('.'));
          } else if (['+', '-', '*', '/', '×', '÷'].contains(action)) {
            String opSym = action == '*' ? '×' : (action == '/' ? '÷' : action);
            return calcButton(opSym, fg: Theme.of(context).primaryColor, onTap: () => setOperation(action.replaceAll('×', '*').replaceAll('÷', '/')));
          } else {
            return calcButton(label, onTap: () => numPress(label));
          }
        }).toList(),
      ),
    );
  }
}

// Floating + rotating + glowing symbols background
class FloatingSymbols extends StatefulWidget {
  final bool isDark;
  const FloatingSymbols({required this.isDark});

  @override
  _FloatingSymbolsState createState() => _FloatingSymbolsState();
}

class _FloatingSymbolsState extends State<FloatingSymbols> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<String> _symbols = ['+', '-', '×', '÷'];
  final int _count = 500;
  late final List<double> _initialLeft;
  late final List<double> _initialTop;
  late final List<double> _size;
  late final List<double> _phase;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat(reverse: true);
    // Pre-generate some random values for stable positions & sizes
    _initialLeft = List.generate(_count, (_) => _random.nextDouble());
    _initialTop = List.generate(_count, (_) => _random.nextDouble());
    _size = List.generate(_count, (_) => 36 + _random.nextDouble() * 36); // 36 - 72
    _phase = List.generate(_count, (_) => _random.nextDouble() * pi * 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _symbolColor(bool isDark, double opacity) {
    if (isDark) {
      return Colors.white24.withOpacity(opacity);
    } else {
      return Colors.black54.withOpacity(opacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Stack(
          children: List.generate(_count, (i) {
            final sym = _symbols[i % _symbols.length];
            // base position
            final left = (_initialLeft[i] * size.width + sin(t * 2 * pi + _phase[i]) * 60) % size.width;
            final top = (_initialTop[i] * size.height * 0.9 + cos(t * 2 * pi + _phase[i]) * 50) % size.height;
            final opacity = (0.08 + 0.25 * (0.5 + 0.5 * sin(t * 2 * pi + _phase[i]))).clamp(0.05, 0.45);
            final rotation = sin(t * 2 * pi + _phase[i]) * 0.7; // radians
            final blurStrength = 8.0 + 12.0 * (0.5 + 0.5 * sin(t * 2 * pi + _phase[i]));
            // glow color depends on theme for subtle contrast
            final glow = widget.isDark ? Colors.blueAccent.withOpacity(0.35) : Colors.deepPurple.withOpacity(0.25);

            return Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: rotation,
                child: Opacity(
                  opacity: opacity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // soft blurred glow behind the symbol (using Container with BoxShadow)
                      Container(
                        width: _size[i] * 1.6,
                        height: _size[i] * 1.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // subtle radial gradient feel via boxShadow
                          boxShadow: [
                            BoxShadow(
                              color: glow,
                              blurRadius: blurStrength,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        sym,
                        style: TextStyle(
                          fontSize: _size[i],
                          fontWeight: FontWeight.w800,
                          color: _symbolColor(widget.isDark, 0.3),
                          shadows: [
                            Shadow(blurRadius: 12, color: glow),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
