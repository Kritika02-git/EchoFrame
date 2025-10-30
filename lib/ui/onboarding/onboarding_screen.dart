import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../utils/images.dart';

class UnlockableOnboarding extends StatefulWidget {
  const UnlockableOnboarding({super.key});

  @override
  State<UnlockableOnboarding> createState() => _UnlockableOnboardingState();
}

class _UnlockableOnboardingState extends State<UnlockableOnboarding>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _unlocked = false;
  Timer? _timer;
  int _secondsLeft = 3;
  StreamSubscription? _shakeSubscription;
  late AnimationController _progressController;
  late ConfettiController _confettiController;
  bool _showTextLogo = false;
  late AnimationController _morphController;

  @override
  void initState() {
    super.initState();

    // Morph animation controller
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

 /*   // Delay morph until Hero animation completes
    Future.delayed(const Duration(milliseconds: 600), () {
      _morphController.forward();
      setState(() {
        _showTextLogo = true;
      });
    });*/

    Future.microtask(() {
      _morphController.forward();
      setState(() {
        _showTextLogo = true;
      });
    });


    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _startUnlockMechanic();
  }

  void _startUnlockMechanic() {
    setState(() {
      _unlocked = false;
      _secondsLeft = 3;
    });

    if (_currentStep == 0) {
      _progressController.reset();
      _progressController.forward();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsLeft > 1) {
          setState(() => _secondsLeft--);
        } else {
          _unlock();
          timer.cancel();
        }
      });
    } else if (_currentStep == 1) {
      _listenForShake();
    } else if (_currentStep == 2) {
      _unlock();
    }
  }

  void _listenForShake() {
    const double shakeThreshold = 3.0;
    _shakeSubscription = userAccelerometerEvents.listen((event) {
      double gForce =
      sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (gForce > shakeThreshold) {
        _unlock();
        _shakeSubscription?.cancel();
      }
    });
  }

  void _unlock() {
    if (!_unlocked) {
      setState(() => _unlocked = true);
      if (_currentStep == 1) _confettiController.play();
    }
  }

  void _nextStep() {
    _timer?.cancel();
    _shakeSubscription?.cancel();

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _startUnlockMechanic();
    } else {
      context.go('/signup');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeSubscription?.cancel();
    _progressController.dispose();
    _confettiController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  Widget _buildStepContent() {
    if (_currentStep == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.2),
                      Colors.transparent
                    ],
                    radius: 0.8,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                ..scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05),
                    duration: 1200.ms),
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _progressController.value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                    const AlwaysStoppedAnimation(Colors.blueAccent),
                  );
                },
              ),
              Text(
                _unlocked ? "✓" : "$_secondsLeft",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _unlocked ? Colors.green : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Time Unlock",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Some echoes reveal themselves only after time has passed.",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_currentStep == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                padding: const EdgeInsets.all(40),
                child: Icon(
                  _unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                  color: _unlocked ? Colors.green : Colors.blueGrey,
                  size: 100,
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shakeX(duration: 700.ms, amount: 4),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Shake Unlock",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _unlocked
                ? "Unlocked by your movement 🎉"
                : "Shake your phone to unlock the next step!",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_unread_rounded,
              size: 100, color: Colors.lightBlueAccent)
              .animate()
              .slideY(begin: -0.3, end: 0, duration: 600.ms)
              .fadeIn(),
          const SizedBox(height: 24),
          Text(
            "Your Journey Begins 🌌",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Compose echoes, seal them, and let time carry them to your future self.",
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  Widget _buildButton() {
    return AnimatedOpacity(
      opacity: _unlocked ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: _unlocked ? _nextStep : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007CF0), Color(0xFF00DFD8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Center(
            child: Text(
              _currentStep == 2 ? "Get Started →" : "Next",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
      ),
    );
  }

  Widget _buildTopLogo() {
    final circularLogo = Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        ImagePath.appLogo,
        fit: BoxFit.cover,
      ),
    );

    if (!_showTextLogo) {
      return Hero(
        tag: "appLogo",
        flightShuttleBuilder: (flightContext, animation,
            flightDirection, fromHeroContext, toHeroContext) {
          final tweenRotate = Tween(begin: 0.0, end: 2 * pi).animate(animation);
          final tweenScale = Tween(begin: 0.9, end: 1.0).animate(animation);
          return AnimatedBuilder(
            animation: animation,
            builder: (_, __) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(
                    20 * sin(animation.value * 2 * pi), // circular motion X
                    20 * cos(animation.value * 2 * pi), // circular motion Y
                  )
                  ..rotateZ(tweenRotate.value)
                  ..scale(tweenScale.value),
                child: circularLogo,
              );
            },
          );
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            ImagePath.appLogo,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return AnimatedBuilder(
        animation: _morphController,
        builder: (context, child) {
          final scale = 1.0 - 0.3 * _morphController.value;
          final opacity = 1.0 - _morphController.value;
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ClipOval(
                      child: Image.asset(
                        ImagePath.appLogo,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: _morphController.value,
                child: Transform.translate(
                  offset: Offset(-20 + 20 * _morphController.value, 0),
                  child: Text(
                    "EchoFrame",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.blueAccent.withOpacity(0.6),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left logo / text
            Positioned(
              top: 16,
              left: 16,
              child: _buildTopLogo(),
            ),

            // Main onboarding content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildStepContent()),
                  _buildButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
