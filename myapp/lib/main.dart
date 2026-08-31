import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AttendanceCalculatorApp());
}

class AttendanceCalculatorApp extends StatelessWidget {
  const AttendanceCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '75% Attendance Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF6A1B9A),
        scaffoldBackgroundColor: const Color(0xFFF8F5FF),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A1B9A),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFF6A1B9A).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const AttendanceCalculatorScreen(),
    );
  }
}

class AttendanceCalculatorScreen extends StatefulWidget {
  const AttendanceCalculatorScreen({super.key});

  @override
  State<AttendanceCalculatorScreen> createState() =>
      _AttendanceCalculatorScreenState();
}

class _AttendanceCalculatorScreenState
    extends State<AttendanceCalculatorScreen> {
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _attendedController = TextEditingController();

  double? _percentage;
  String _resultMessage = '';
  String _status = ''; // "safe", "danger", "perfect"
  bool _hasCalculated = false;

  void _calculate() {
    final total = int.tryParse(_totalController.text.trim());
    final attended = int.tryParse(_attendedController.text.trim());

    if (total == null || attended == null || total <= 0) {
      setState(() {
        _hasCalculated = false;
        _resultMessage = 'Please enter valid numbers (Total > 0)';
        _status = '';
      });
      return;
    }

    if (attended > total) {
      setState(() {
        _hasCalculated = false;
        _resultMessage = 'Attended lectures cannot be more than Total lectures';
        _status = '';
      });
      return;
    }

    if (attended < 0) {
      setState(() {
        _hasCalculated = false;
        _resultMessage = 'Attended lectures cannot be negative';
        _status = '';
      });
      return;
    }

    final percentage = (attended / total) * 100;

    String message;
    String status;

    if (percentage >= 75) {
      // How many can be bunked while staying ≥ 75%
      // Max bunks y such that attended / (total + y) ≥ 0.75
      // y ≤ (attended / 0.75) - total
      final maxBunk = ((attended / 0.75) - total).floor();

      if (maxBunk <= 0) {
        message =
            'You are exactly at the edge.\nYou cannot bunk any more classes.';
        status = 'perfect';
      } else {
        message =
            'You can safely bunk\n$maxBunk more class${maxBunk == 1 ? '' : 'es'}\nwhile staying above 75%.';
        status = 'safe';
      }
    } else {
      // Classes needed to reach 75%
      // (attended + x) / (total + x) ≥ 0.75
      // x ≥ (0.75 * total - attended) / 0.25
      // x ≥ 3 * total - 4 * attended
      final needed = ((0.75 * total - attended) / 0.25).ceil();

      if (needed <= 0) {
        message = 'You have already reached 75%!';
        status = 'perfect';
      } else {
        message =
            'You need to attend\n$needed more class${needed == 1 ? '' : 'es'}\nto reach 75% attendance.';
        status = 'danger';
      }
    }

    setState(() {
      _percentage = percentage;
      _resultMessage = message;
      _status = status;
      _hasCalculated = true;
    });
  }

  void _reset() {
    _totalController.clear();
    _attendedController.clear();
    setState(() {
      _percentage = null;
      _resultMessage = '';
      _status = '';
      _hasCalculated = false;
    });
  }

  Color get _statusColor {
    switch (_status) {
      case 'safe':
        return const Color(0xFF2E7D32);
      case 'danger':
        return const Color(0xFFC62828);
      case 'perfect':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'safe':
        return Icons.check_circle_rounded;
      case 'danger':
        return Icons.warning_rounded;
      case 'perfect':
        return Icons.star_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    _attendedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6A1B9A),
                    Color(0xFF9C27B0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '75% Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Calculator',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Input Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A1B9A).withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enter Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A148C),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _totalController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Total Lectures',
                              labelStyle: TextStyle(color: Color(0xFF7B1FA2)),
                              prefixIcon: Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF6A1B9A),
                              ),
                              hintText: 'e.g. 40',
                            ),
                            onChanged: (_) {
                              if (_hasCalculated) _calculate();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _attendedController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Attended Lectures',
                              labelStyle: TextStyle(color: Color(0xFF7B1FA2)),
                              prefixIcon: Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFF6A1B9A),
                              ),
                              hintText: 'e.g. 28',
                            ),
                            onChanged: (_) {
                              if (_hasCalculated) _calculate();
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _calculate,
                                  icon: const Icon(Icons.calculate_rounded),
                                  label: const Text(
                                    'Calculate',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: _reset,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6A1B9A),
                                  side: const BorderSide(
                                    color: Color(0xFF6A1B9A),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Icon(Icons.refresh_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Result Card
                    if (_hasCalculated) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _statusColor.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: _statusColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Percentage Circle
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _statusColor.withOpacity(0.15),
                                    _statusColor.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: _statusColor,
                                  width: 4,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${_percentage!.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Icon(
                              _statusIcon,
                              color: _statusColor,
                              size: 36,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _resultMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: _statusColor,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _status == 'safe'
                                  ? 'You are safe!'
                                  : _status == 'danger'
                                      ? 'Action required'
                                      : 'Perfect!',
                              style: TextStyle(
                                fontSize: 14,
                                color: _statusColor.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Placeholder when no calculation yet
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE1BEE7),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 48,
                              color: Colors.purple.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Enter your lecture details\nand tap Calculate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.purple.withOpacity(0.6),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Info tip
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Color(0xFF7B1FA2),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Most colleges require minimum 75% attendance to appear in exams.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.purple[800],
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Banner Ad Placeholder
            Container(
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD1C4E9),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.ad_units_rounded,
                      color: Color(0xFF7B1FA2),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Banner Ad Placeholder',
                      style: TextStyle(
                        color: Color(0xFF7B1FA2),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
