import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/images.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text("Send to Future"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("View Echoes"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EchoFrame"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {}, // go to profile
              child: const CircleAvatar(
                backgroundImage: AssetImage("assets/profile.png"),
              ),
            ),
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to EchoFrame!",
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: Hero(
        tag: "appLogo",
        child: GestureDetector(
          onTap: () => _showOptions(context),
          child: AnimatedLogoFAB(),
        ),
      ),
    );
  }
}

// ---------------- FAB with Pulse ----------------

class AnimatedLogoFAB extends StatefulWidget {
  const AnimatedLogoFAB({super.key});

  @override
  State<AnimatedLogoFAB> createState() => _AnimatedLogoFABState();
}

class _AnimatedLogoFABState extends State<AnimatedLogoFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  ClipOval(child: Image.asset(ImagePath.appLogo, fit: BoxFit.cover, width: 50, height: 50,));// same logo
  }
}