import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: TimeTimer(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TimeTimer extends StatefulWidget {
  final int maxSeconds;
  const TimeTimer({super.key, this.maxSeconds = 60 * 60}); // 최대 60분(3600초)

  @override
  State<TimeTimer> createState() => _TimeTimerState();
}

class _TimeTimerState extends State<TimeTimer> with SingleTickerProviderStateMixin {
  late int _secondsLeft;
  late int _maxSeconds;
  AnimationController? _controller;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _maxSeconds = widget.maxSeconds;
    _secondsLeft = _maxSeconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _maxSeconds),
    )..addListener(() {
        setState(() {
          _secondsLeft = _maxSeconds - (_controller!.value * _maxSeconds).round();
        });
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _start() {
    if (_secondsLeft > 0) {
      _controller?.forward(from: (_maxSeconds - _secondsLeft) / _maxSeconds);
      setState(() => _isRunning = true);
    }
  }

  void _pause() {
    _controller?.stop();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _controller?.reset();
    setState(() {
      _secondsLeft = _maxSeconds;
      _isRunning = false;
    });
  }

  void _setMinutes(int minutes) {
    _maxSeconds = minutes * 60;
    _reset();
    _controller?.duration = Duration(seconds: _maxSeconds);
  }

  @override
  Widget build(BuildContext context) {
    double percent = _secondsLeft / _maxSeconds;
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        size = size * 0.9; // 패딩을 위해 90%만 사용
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: TimerPainter(percent: percent),
                child: Center(
                  child: Text(
                    '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  iconSize: 36,
                  onPressed: _isRunning ? _pause : _start,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  iconSize: 36,
                  onPressed: _reset,
                ),
                PopupMenuButton<int>(
                  icon: const Icon(Icons.timer),
                  itemBuilder: (context) => [5, 10, 15, 20, 30, 60]
                      .map((m) => PopupMenuItem(value: m, child: Text('$m분')))
                      .toList(),
                  onSelected: _setMinutes,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class TimerPainter extends CustomPainter {
  final double percent; // 0.0 ~ 1.0
  TimerPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    final Paint fgPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    // Draw background
    canvas.drawCircle(center, radius, bgPaint);
    // Draw red arc
    double sweepAngle = 2 * 3.141592 * percent;
    Path path = Path();
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592 / 2,
      sweepAngle,
      false,
    );
    path.close();
    canvas.drawPath(path, fgPaint);

    // Draw minute ticks
    for (int i = 0; i < 60; i++) {
      double tickAngle = (i / 60) * 2 * 3.141592 - 3.141592 / 2;
      double outer = radius;
      double inner = radius * 0.88;
      double thickness = 2;
      if (i % 15 == 0) {
        inner = radius * 0.80;
        thickness = 6;
      } else if (i % 5 == 0) {
        inner = radius * 0.84;
        thickness = 4;
      }
      final Paint tickPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      final Offset p1 = Offset(center.dx + outer * cos(tickAngle), center.dy + outer * sin(tickAngle));
      final Offset p2 = Offset(center.dx + inner * cos(tickAngle), center.dy + inner * sin(tickAngle));
      canvas.drawLine(p1, p2, tickPaint);
      // Draw numbers for 0, 15, 30, 45
      if (i % 15 == 0) {
        String label = i == 0 ? '0' : '${i}';
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: Colors.black,
              fontSize: radius * 0.13,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final labelRadius = radius * 0.68;
        final labelAngle = tickAngle;
        final Offset labelOffset = Offset(
          center.dx + labelRadius * cos(labelAngle) - textPainter.width / 2,
          center.dy + labelRadius * sin(labelAngle) - textPainter.height / 2,
        );
        textPainter.paint(canvas, labelOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}
