import 'dart:async';

import 'package:driver_voice_engine/driver_voice_engine.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _capabilities = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadCapabilities();
  }

  Future<void> _loadCapabilities() async {
    try {
      final caps = await DriverVoiceEngine.instance.getCapabilities();
      if (!mounted) return;
      setState(() {
        _capabilities =
            'Telecom: ${caps.supportsTelecom}, Proximity: ${caps.supportsProximity}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _capabilities = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Driver Voice Engine Example')),
        body: Center(child: Text('Engine: $_capabilities\n')),
      ),
    );
  }
}
