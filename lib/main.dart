import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'dart:async';

void main() {
  runApp(const ZenFocusApp());
}

class ZenFocusApp extends StatelessWidget {
  const ZenFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zen Focus',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const FocusScreen(),
    );
  }
}

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

enum FocusState { idle, ready, running, failed, success }

class _FocusScreenState extends State<FocusScreen> {
  int _workMinutes = 25;
  int _secondsRemaining = 25 * 60;
  FocusState _currentState = FocusState.idle;
  
  Timer? _timer;
  StreamSubscription? _accelSubscription;
  final double _tiltThreshold = 2.0; 

  @override
  void initState() {
    super.initState();
  }

  void _startListeningSensors() {
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_currentState == FocusState.ready) {
        if (event.x.abs() < _tiltThreshold && event.y.abs() < _tiltThreshold) {
          _startTimer();
        }
      } else if (_currentState == FocusState.running) {
        if (event.x.abs() > _tiltThreshold || event.y.abs() > _tiltThreshold) {
          _failFocus();
        }
      }
    });
  }

  void _prepareToFocus() {
    setState(() {
      _currentState = FocusState.ready;
      _secondsRemaining = _workMinutes * 60;
    });
    _startListeningSensors();
  }

  void _startTimer() {
    setState(() => _currentState = FocusState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _completeFocus();
        }
      });
    });
  }

  // ---- NUOVA FUNZIONE: PUNIZIONE (Vibrazione + Torcia) ----
  Future<void> _triggerFailureFeedback() async {
    // 1. Vibrazione "rabbiosa" (pausa, vibra, pausa, vibra)
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]); 
    }

    // 2. Torcia che lampeggia 3 volte
    try {
      bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (isTorchAvailable) {
        for (int i = 0; i < 3; i++) {
          await TorchLight.enableTorch();
          await Future.delayed(const Duration(milliseconds: 150));
          await TorchLight.disableTorch();
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }
    } catch (e) {
      debugPrint("Errore con la torcia: $e"); // Ignora silenziosamente se la torcia non c'è
    }
  }

  // ---- NUOVA FUNZIONE: PREMIO (Solo Vibrazione Felice) ----
  Future<void> _triggerSuccessFeedback() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Vibrazione breve e ritmata (tipo "Ta-Da!")
      Vibration.vibrate(pattern: [0, 150, 100, 150, 100, 400]); 
    }
  }

  void _failFocus() {
    _timer?.cancel();
    _accelSubscription?.cancel();
    setState(() => _currentState = FocusState.failed);
    _triggerFailureFeedback(); // Chiamo il feedback negativo
  }

  void _completeFocus() {
    _timer?.cancel();
    _accelSubscription?.cancel();
    setState(() => _currentState = FocusState.success);
    _triggerSuccessFeedback(); // Chiamo il feedback positivo
  }

  void _reset() {
    _timer?.cancel();
    _accelSubscription?.cancel();
    setState(() {
      _currentState = FocusState.idle;
      _secondsRemaining = _workMinutes * 60;
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... IL METODO BUILD RIMANE IDENTICO AL PRECEDENTE ...
    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (_currentState == FocusState.idle) {
            if (details.primaryVelocity! < 0 && _workMinutes < 120) {
              setState(() {
                _workMinutes += 5;
                _secondsRemaining = _workMinutes * 60;
              });
            } else if (details.primaryVelocity! > 0 && _workMinutes > 5) {
              setState(() {
                _workMinutes -= 5;
                _secondsRemaining = _workMinutes * 60;
              });
            }
          }
        },
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 50),
              _buildTimerDisplay(),
              const SizedBox(height: 50),
              _buildActionArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String message = '';
    Color color = Colors.white;

    switch (_currentState) {
      case FocusState.idle:
        message = 'Swipe ↕ per impostare il timer\nPremi START per iniziare';
        color = Colors.grey;
        break;
      case FocusState.ready:
        message = 'Appoggia il telefono\nsu un piano per iniziare';
        color = Colors.orangeAccent;
        break;
      case FocusState.running:
        message = 'Shhh... Concentrazione!\nNon toccare il telefono.';
        color = Colors.tealAccent;
        break;
      case FocusState.failed:
        message = 'Ti sei distratto!\nBusted! 🔦';
        color = Colors.redAccent;
        break;
      case FocusState.success:
        message = 'Bravissimo!\nSessione completata.';
        color = Colors.greenAccent;
        break;
    }

    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTimerDisplay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _currentState == FocusState.running ? Colors.tealAccent : Colors.white24,
          width: 8,
        ),
        boxShadow: _currentState == FocusState.running
            ? [BoxShadow(color: Colors.tealAccent.withOpacity(0.5), blurRadius: 30)]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        _formatTime(_secondsRemaining),
        style: TextStyle(
          fontSize: 60,
          fontWeight: FontWeight.bold,
          color: _currentState == FocusState.failed ? Colors.redAccent : Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    if (_currentState == FocusState.idle) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: _prepareToFocus,
        child: const Text('START', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      );
    } else {
      return TextButton(
        onPressed: _reset,
        child: const Text('RESET / ANNULLA', style: TextStyle(color: Colors.grey, fontSize: 18)),
      );
    }
  }
}