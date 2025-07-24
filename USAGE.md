# Native TextField TV 使用指南

## 概述

Native TextField TV 是一个Flutter插件，使用PlatformView在Android平台上实现原生TextField组件。它提供了与Flutter TextField类似的功能，但使用Android原生的EditText组件。

## 主要特性

- ✅ 使用Android原生EditText组件
- ✅ 支持FocusNode焦点管理
- ✅ 实时文本内容获取和设置
- ✅ 支持提示文本和初始文本
- ✅ 支持启用/禁用状态
- ✅ 支持焦点变化监听
- ✅ 支持文本变化监听
- ✅ 支持控制器模式操作

## 快速开始

### 1. 添加依赖

在你的`pubspec.yaml`文件中添加依赖：

```yaml
dependencies:
  native_textfield_tv: ^0.0.1
```

### 2. 基本使用

```dart
import 'package:flutter/material.dart';
import 'package:native_textfield_tv/native_textfield_tv.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final FocusNode _focusNode = FocusNode();
  String _textContent = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NativeTextField(
          hint: '请输入文本...',
          initialText: '初始文本',
          focusNode: _focusNode,
          onChanged: (text) {
            setState(() {
              _textContent = text;
            });
          },
          onFocusChanged: (hasFocus) {
            print('焦点变化: $hasFocus');
          },
          width: double.infinity,
          height: 50,
        ),
        Text('当前文本: $_textContent'),
        ElevatedButton(
          onPressed: () => _focusNode.requestFocus(),
          child: Text('请求焦点'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
```

## 高级用法

### 使用控制器

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  NativeTextFieldController? _controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NativeTextField(
          hint: '请输入文本...',
          onChanged: (text) {
            // 文本变化回调
          },
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                // 获取文本内容
                final text = await _controller?.getText();
                print('当前文本: $text');
              },
              child: Text('获取文本'),
            ),
            ElevatedButton(
              onPressed: () {
                // 设置文本内容
                _controller?.setText('新文本');
              },
              child: Text('设置文本'),
            ),
            ElevatedButton(
              onPressed: () {
                // 请求焦点
                _controller?.requestFocus();
              },
              child: Text('请求焦点'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 表单验证

```dart
class FormExample extends StatefulWidget {
  @override
  _FormExampleState createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  String _email = '';
  String _password = '';
  String _emailError = '';
  String _passwordError = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          NativeTextField(
            hint: '邮箱地址',
            focusNode: _emailFocusNode,
            onChanged: (text) {
              setState(() {
                _email = text;
                _emailError = _validateEmail(text);
              });
            },
            onFocusChanged: (hasFocus) {
              if (!hasFocus && _emailError.isNotEmpty) {
                // 失去焦点时显示错误
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_emailError)),
                );
              }
            },
          ),
          if (_emailError.isNotEmpty)
            Text(_emailError, style: TextStyle(color: Colors.red)),
          
          const SizedBox(height: 16),
          
          NativeTextField(
            hint: '密码',
            focusNode: _passwordFocusNode,
            onChanged: (text) {
              setState(() {
                _password = text;
                _passwordError = _validatePassword(text);
              });
            },
          ),
          if (_passwordError.isNotEmpty)
            Text(_passwordError, style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  String _validateEmail(String email) {
    if (email.isEmpty) return '邮箱不能为空';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return '邮箱格式不正确';
    }
    return '';
  }

  String _validatePassword(String password) {
    if (password.isEmpty) return '密码不能为空';
    if (password.length < 6) return '密码长度不能少于6位';
    return '';
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
```

## API 参考

### NativeTextField Widget

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `hint` | `String?` | 否 | 提示文本 |
| `initialText` | `String?` | 否 | 初始文本 |
| `focusNode` | `FocusNode?` | 否 | 焦点节点 |
| `onChanged` | `ValueChanged<String>?` | 否 | 文本变化回调 |
| `onFocusChanged` | `ValueChanged<bool>?` | 否 | 焦点变化回调 |
| `enabled` | `bool` | 否 | 是否启用，默认为true |
| `width` | `double?` | 否 | 宽度 |
| `height` | `double?` | 否 | 高度 |

### NativeTextFieldController

| 方法 | 返回类型 | 描述 |
|------|----------|------|
| `setText(String text)` | `Future<void>` | 设置文本内容 |
| `getText()` | `Future<String>` | 获取文本内容 |
| `requestFocus()` | `Future<void>` | 请求焦点 |
| `clearFocus()` | `Future<void>` | 清除焦点 |
| `setEnabled(bool enabled)` | `Future<void>` | 设置启用状态 |
| `setHint(String hint)` | `Future<void>` | 设置提示文本 |

## 注意事项

1. **平台支持**: 目前只支持Android平台，iOS和Web平台暂未实现。

2. **性能考虑**: 使用PlatformView会有一定的性能开销，建议在需要原生功能时才使用此插件。

3. **焦点管理**: 确保正确管理FocusNode的生命周期，在dispose时调用`dispose()`方法。

4. **文本编码**: 插件支持UTF-8编码的文本内容。

5. **样式定制**: 目前插件使用Android原生的EditText样式，如需自定义样式，需要在Android端进行修改。

## 故障排除

### 常见问题

1. **插件无法加载**
   - 确保在`pubspec.yaml`中正确添加了依赖
   - 运行`flutter pub get`更新依赖

2. **Android构建失败**
   - 确保Android SDK版本正确
   - 检查Gradle配置是否正确

3. **文本输入无响应**
   - 检查是否正确设置了`onChanged`回调
   - 确保FocusNode正确配置

4. **焦点管理问题**
   - 确保FocusNode在dispose时正确释放
   - 检查是否有其他Widget干扰焦点

### 调试技巧

1. 使用`print`语句在回调中输出调试信息
2. 检查MethodChannel的通信是否正常
3. 在Android Studio中查看Logcat输出

## 贡献

欢迎提交Issue和Pull Request来改进这个插件！

## 许可证

MIT License 