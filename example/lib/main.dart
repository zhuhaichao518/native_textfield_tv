import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_textfield_tv/native_textfield_tv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _textContent = '';
  
  // Clear focus node names for better readability
  final FocusNode _firstTextFieldFocus = FocusNode();
  final FocusNode _secondTextFieldFocus = FocusNode();
  
  // Clear controller names
  final NativeTextFieldController _firstController = NativeTextFieldController();
  final NativeTextFieldController _secondController = NativeTextFieldController(text: 'Initial text');

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await NativeTextfieldTv().getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native TextField TV Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native TextField TV Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Platform info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform Info',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Platform Version: $_platformVersion'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Main demo card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Native TextField Demo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Row 1: Control buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _secondController.setText('New text from button');
                              setState(() {
                                _textContent = _secondController.text;
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Set Text'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _secondController.clear();
                              setState(() {
                                _textContent = _secondController.text;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Text'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Row 2: First TextField
                      DpadNativeTextField(
                        focusNode: _firstTextFieldFocus, 
                        controller: _firstController,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Row 3: Second TextField
                      DpadNativeTextField(
                        focusNode: _secondTextFieldFocus, 
                        controller: _secondController,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Row 4: Focus control button
                      ElevatedButton.icon(
                        onPressed: () {
                          _firstTextFieldFocus.requestFocus();
                        },
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Focus to First TextField'),
                      ),
                      
                      const SizedBox(height: 16),
                      Text('Current text content: $_textContent'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstTextFieldFocus.dispose();
    _secondTextFieldFocus.dispose();
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }
}
