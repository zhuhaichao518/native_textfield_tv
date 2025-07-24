import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_textfield_tv/native_textfield_tv.dart';
import 'package:native_textfield_tv_example/dpad_widget.dart';

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
                        '平台信息',
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
                      /*DpadTextField(focusNode: _focusNode0, child:                       NativeTextField(
                        hint: '请输入文本...',
                        initialText: '初始文本',
                        focusNode: _focusNode1,
                        onChanged: (text) {
                          setState(() {
                            _textContent = text;
                          });
                        },
                        onFocusChanged: (hasFocus) {
                          // 焦点变化处理
                        },
                        width: double.infinity,
                        height: 50,
                      ),),*/
                      DpadNativeTextField(focusNode: _focusNode0, controller: NativeTextFieldController(),),
                      Text(
                        'Native TextField 演示',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text('输入框:'),
                      const SizedBox(height: 8),
                      /*NativeTextField(
                        hint: '请输入文本...',
                        initialText: '初始文本',
                        focusNode: _focusNode,
                        onChanged: (text) {
                          setState(() {
                            _textContent = text;
                          });
                        },
                        onFocusChanged: (hasFocus) {
                          // 焦点变化处理
                        },
                        width: double.infinity,
                        height: 50,
                      ),*/
                      const SizedBox(height: 16),
                      Text('当前文本内容: $_textContent'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _focusNode.requestFocus();
                            },
                            icon: const Icon(Icons.keyboard),
                            label: const Text('请求焦点'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _focusNode.unfocus();
                            },
                            icon: const Icon(Icons.keyboard_hide),
                            label: const Text('清除焦点'),
                          ),
                        ],
                      ),
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
    super.dispose();
  }
}
