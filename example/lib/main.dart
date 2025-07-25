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

  final FocusNode _firstTextFieldFocus = FocusNode();
  final FocusNode _secondTextFieldFocus = FocusNode();
  final FocusNode _thirdTextFieldFocus = FocusNode();

  // 使用同一个 controller 管理多个文本框
  final NativeTextFieldController _sharedController = NativeTextFieldController();
  
  // 独立的 controller
  final NativeTextFieldController _independentController = NativeTextFieldController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await NativeTextfieldTv().getPlatformVersion() ??
          'Unknown platform version';
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Native TextField TV Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
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
                        'Shared Controller Demo (多个文本框共享同一个controller)',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _sharedController.setText('共享文本更新');
                              setState(() {
                                _textContent = _sharedController.text;
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('更新共享文本'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _sharedController.clear();
                              setState(() {
                                _textContent = _sharedController.text;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('清空共享文本'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('共享Controller的文本框1:'),
                      DpadNativeTextField(
                        focusNode: _firstTextFieldFocus,
                        controller: _sharedController,
                      ),
                      const SizedBox(height: 16),
                      Text('共享Controller的文本框2:'),
                      DpadNativeTextField(
                        focusNode: _secondTextFieldFocus,
                        controller: _sharedController,
                      ),
                      const SizedBox(height: 16),
                      Text('独立Controller的文本框:'),
                      DpadNativeTextField(
                        focusNode: _thirdTextFieldFocus,
                        controller: _independentController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _firstTextFieldFocus.requestFocus();
                            },
                            icon: const Icon(Icons.keyboard),
                            label: const Text('焦点到共享文本框1'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _secondTextFieldFocus.requestFocus();
                            },
                            icon: const Icon(Icons.keyboard),
                            label: const Text('焦点到共享文本框2'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _thirdTextFieldFocus.requestFocus();
                            },
                            icon: const Icon(Icons.keyboard),
                            label: const Text('焦点到独立文本框'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('共享Controller当前文本: $_textContent'),
                      const SizedBox(height: 8),
                      Text('独立Controller当前文本: ${_independentController.text}'),
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
    _thirdTextFieldFocus.dispose();
    _sharedController.dispose();
    _independentController.dispose();
    super.dispose();
  }
}
