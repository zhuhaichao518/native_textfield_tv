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
  
  // 创建控制器 - 现在可以像 TextEditingController 一样使用
  final NativeTextFieldController _controller = NativeTextFieldController(text: '初始文本');
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
                        ElevatedButton.icon(
                            onPressed: () async {
                              final text = await _controller.getText();
                              setState(() {
                                _textContent = text;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('获取文本'),
                          ),
                      Text(
                        'Native TextField 演示',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text('输入框:'),
                      const SizedBox(height: 8),
                      DpadNativeTextField(
                        focusNode: _focusNode1, 
                        controller: _controller1,
                      ),
                      DpadNativeTextField(
                        focusNode: _focusNode0, 
                        controller: _controller,
                      ),
                      const SizedBox(height: 16),
                      Text('当前文本内容: $_textContent'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _focusNode0.requestFocus();
                            },
                            icon: const Icon(Icons.keyboard),
                            label: const Text('请求焦点'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _focusNode0.unfocus();
                            },
                            icon: const Icon(Icons.keyboard_hide),
                            label: const Text('清除焦点'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final text = await _controller.getText();
                              setState(() {
                                _textContent = text;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('获取文本'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              _controller.setText('设置的新文本');
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('设置文本'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('TextEditingController 功能演示:'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // 使用 TextEditingController 的 text 属性
                              _controller.text = '通过 text 属性设置';
                              setState(() {
                                _textContent = _controller.text;
                              });
                            },
                            icon: const Icon(Icons.text_fields),
                            label: const Text('text 属性'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              // 使用 TextEditingController 的 selection 属性
                              _controller.text = '测试选择文本';
                              _controller.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: 4,
                              );
                              setState(() {
                                _textContent = _controller.text;
                              });
                            },
                            icon: const Icon(Icons.select_all),
                            label: const Text('选择文本'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              // 使用 TextEditingController 的 clear 方法
                              _controller.clear();
                              setState(() {
                                _textContent = _controller.text;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('清空文本'),
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
    _focusNode0.dispose();
    _focusNode1.dispose();
    _controller.dispose();
    super.dispose();
  }
}
