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
- **NativeTextFieldController 继承自 TextEditingController，提供完整的文本编辑功能**

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

### 使用控制器（TextEditingController 兼容）

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 创建控制器，支持初始文本
  final NativeTextFieldController _controller = NativeTextFieldController(text: '初始文本');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NativeTextField(
          controller: _controller,
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
                final text = await _controller.getText();
                print('当前文本: $text');
              },
              child: Text('获取文本'),
            ),
            ElevatedButton(
              onPressed: () {
                // 设置文本内容 - 使用 setText 方法
                _controller.setText('新文本');
              },
              child: Text('设置文本'),
            ),
            ElevatedButton(
              onPressed: () {
                // 使用 TextEditingController 的 text 属性
                _controller.text = '通过 text 属性设置';
              },
              child: Text('text 属性'),
            ),
            ElevatedButton(
              onPressed: () {
                // 使用 TextEditingController 的 clear 方法
                _controller.clear();
              },
              child: Text('清空文本'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 监听器模式

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final NativeTextFieldController _controller = NativeTextFieldController();

  @override
  void initState() {
    super.initState();
    
    // 添加监听器
    _controller.addListener(() {
      print('文本变化: ${_controller.text}');
      setState(() {
        // 更新UI
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NativeTextField(
      controller: _controller,
      hint: '请输入文本...',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

**继承自 TextEditingController，提供所有 TextEditingController 功能：**

| 属性/方法 | 类型 | 描述 |
|-----------|------|------|
| `text` | `String` | 文本内容（继承自 TextEditingController） |
| `selection` | `TextSelection` | 文本选择（继承自 TextEditingController） |
| `addListener(VoidCallback listener)` | `void` | 添加监听器（继承自 TextEditingController） |
| `removeListener(VoidCallback listener)` | `void` | 移除监听器（继承自 TextEditingController） |
| `clear()` | `void` | 清空文本（继承自 TextEditingController） |
| `setText(String text)` | `Future<void>` | 设置文本内容 |
| `getText()` | `Future<String>` | 获取文本内容 |
| `requestFocus()` | `Future<void>` | 请求焦点 |
| `clearFocus()` | `Future<void>` | 清除焦点 |
| `setEnabled(bool enabled)` | `Future<void>` | 设置启用状态 |
| `setHint(String hint)` | `Future<void>` | 设置提示文本 |
| `onFocusChanged` | `ValueChanged<bool>?` | 焦点变化回调 |

## 平台支持

- ✅ Android (使用PlatformView)
- ❌ iOS (暂未实现)
- ❌ Web (暂未实现)

## 开发说明

这个插件使用Flutter的PlatformView机制，在Android平台上创建原生的EditText组件。通过MethodChannel实现Flutter和原生代码之间的通信。

**重要更新：** NativeTextFieldController 现在继承自 TextEditingController，这意味着：

1. **完全兼容**：可以在任何需要 TextEditingController 的地方使用
2. **同步操作**：支持同步的文本操作（如 `controller.text = 'new text'`）
3. **监听器支持**：支持 `addListener` 和 `removeListener`
4. **自动同步**：文本变化会自动同步到原生端
5. **双向绑定**：原生端的文本变化也会同步到 Flutter 端

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
