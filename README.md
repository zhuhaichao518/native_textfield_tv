# Native TextField TV

一个Flutter插件，使用PlatformView在Android平台上实现原生TextField组件。

## 功能特性

- 使用Android原生EditText组件
- 支持FocusNode焦点管理
- 实时文本内容获取
- 支持提示文本和初始文本
- 支持启用/禁用状态
- 支持焦点变化监听
- 支持文本变化监听

## 安装

在你的`pubspec.yaml`文件中添加依赖：

```yaml
dependencies:
  native_textfield_tv: ^0.0.1
```

## 使用方法

### 基本用法

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
      ],
    );
  }
}
```

## API 参考

### NativeTextField

| 参数 | 类型 | 描述 |
|------|------|------|
| `hint` | `String?` | 提示文本 |
| `initialText` | `String?` | 初始文本 |
| `focusNode` | `FocusNode?` | 焦点节点 |
| `onChanged` | `ValueChanged<String>?` | 文本变化回调 |
| `onFocusChanged` | `ValueChanged<bool>?` | 焦点变化回调 |
| `enabled` | `bool` | 是否启用，默认为true |
| `width` | `double?` | 宽度 |
| `height` | `double?` | 高度 |

### NativeTextFieldController

| 方法 | 描述 |
|------|------|
| `setText(String text)` | 设置文本内容 |
| `getText()` | 获取文本内容 |
| `requestFocus()` | 请求焦点 |
| `clearFocus()` | 清除焦点 |
| `setEnabled(bool enabled)` | 设置启用状态 |
| `setHint(String hint)` | 设置提示文本 |

## 平台支持

- ✅ Android (使用PlatformView)
- ❌ iOS (暂未实现)
- ❌ Web (暂未实现)

## 开发说明

这个插件使用Flutter的PlatformView机制，在Android平台上创建原生的EditText组件。通过MethodChannel实现Flutter和原生代码之间的通信。

### 项目结构

```
lib/
├── native_textfield_tv.dart              # 主要API
├── native_textfield_tv_platform_interface.dart  # 平台接口
└── native_textfield_tv_method_channel.dart      # 方法通道实现

android/src/main/kotlin/com/example/native_textfield_tv/
├── NativeTextfieldTvPlugin.kt            # 插件主类
└── NativeTextfieldTvView.kt              # PlatformView实现
```

## 许可证

MIT License
