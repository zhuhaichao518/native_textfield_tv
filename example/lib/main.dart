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
  final FocusNode _focusNode = FocusNode();

  final FocusNode _focusNode0 = FocusNode();
  final FocusNode _focusNode1 = FocusNode();
  
  // Create controllers - now works like TextEditingController
  final NativeTextFieldController _controller = NativeTextFieldController(text: 'Initial text');
  final NativeTextFieldController _controller1 = NativeTextFieldController();

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
                      
                      // First row: Set text and Clear text buttons
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _controller.setText('New text from button');
                              setState(() {
                                _textContent = _controller.text;
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Set Text'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _controller.clear();
                              setState(() {
                                _textContent = _controller.text;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Text'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Second row: First DpadNativeTextField
                      DpadNativeTextField(
                        focusNode: _focusNode1, 
                        controller: _controller1,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Third row: Second DpadNativeTextField
                      DpadNativeTextField(
                        focusNode: _focusNode0, 
                        controller: _controller,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Fourth row: Focus button
                      ElevatedButton.icon(
                        onPressed: () {
                          _focusNode1.requestFocus();
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
    _focusNode.dispose();
    _focusNode0.dispose();
    _focusNode1.dispose();
    _controller.dispose();
    super.dispose();
  }
}
