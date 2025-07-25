# Native TextField TV

A Flutter plugin that provides native Android EditText component as a solution for Android TV remote control issues with Flutter's default TextField.

## 🚨 Problem Statement

According to [Flutter issue #154924](https://github.com/flutter/flutter/issues/154924), Flutter's default `TextField` doesn't work properly with TV remotes on many Android TV devices (including Google Chromecast). The keyboard appears but arrow key navigation through letters doesn't work because the Flutter app keeps focus.

**This plugin provides a native Android solution** that bypasses this limitation by using Android's native `EditText` component through PlatformView.

## ✨ Features

- **Android TV Remote Compatible**: Works perfectly with TV remote controls
- **Native Android EditText**: Uses Android's native text input component
- **Full TextEditingController Compatibility**: Inherits from TextEditingController for seamless integration
- **Focus Management**: Complete focus control with FocusNode support
- **Real-time Text Access**: Get and set text content in real-time
- **Customizable**: Support for hints, initial text, and styling
- **Platform Support**: Currently supports Android (TV and mobile)

## 🎯 Use Cases

- **Android TV Apps**: Perfect for apps that need text input on Android TV
- **Chromecast Apps**: Solves the remote control input issue on Chromecast devices
- **TV Remote Navigation**: Full compatibility with TV remote arrow keys and selection
- **Legacy Flutter Apps**: Drop-in replacement for problematic TextField instances

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  native_textfield_tv: ^0.0.2
```

## 🚀 Usage

### Basic Usage (Perfect for Android TV)

```dart
import 'package:flutter/material.dart';
import 'package:native_textfield_tv/native_textfield_tv.dart';

class MyTVWidget extends StatefulWidget {
  @override
  _MyTVWidgetState createState() => _MyTVWidgetState();
}

class _MyTVWidgetState extends State<MyTVWidget> {
  final FocusNode _focusNode = FocusNode();
  String _textContent = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // This works perfectly with TV remote controls!
        NativeTextField(
          hint: 'Enter text using your TV remote...',
          initialText: 'Initial text',
          focusNode: _focusNode,
          onChanged: (text) {
            setState(() {
              _textContent = text;
            });
          },
          onFocusChanged: (hasFocus) {
            print('Focus changed: $hasFocus');
          },
          width: double.infinity,
          height: 50,
        ),
        Text('Current text: $_textContent'),
        ElevatedButton(
          onPressed: () => _focusNode.requestFocus(),
          child: Text('Request Focus'),
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

### Using Controller (TextEditingController Compatible)

```dart
class MyTVWidget extends StatefulWidget {
  @override
  _MyTVWidgetState createState() => _MyTVWidgetState();
}

class _MyTVWidgetState extends State<MyTVWidget> {
  // Create controller with initial text
  final NativeTextFieldController _controller = NativeTextFieldController(text: 'Initial text');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NativeTextField(
          controller: _controller,
          hint: 'Enter text with TV remote...',
          onChanged: (text) {
            // Text change callback
          },
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Get text content
                final text = await _controller.getText();
                print('Current text: $text');
              },
              child: Text('Get Text'),
            ),
            ElevatedButton(
              onPressed: () {
                // Set text content using setText method
                _controller.setText('New text');
              },
              child: Text('Set Text'),
            ),
            ElevatedButton(
              onPressed: () {
                // Use TextEditingController's text property
                _controller.text = 'Set via text property';
              },
              child: Text('Text Property'),
            ),
            ElevatedButton(
              onPressed: () {
                // Use TextEditingController's clear method
                _controller.clear();
              },
              child: Text('Clear Text'),
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

### Listener Pattern

```dart
class MyTVWidget extends StatefulWidget {
  @override
  _MyTVWidgetState createState() => _MyTVWidgetState();
}

class _MyTVWidgetState extends State<MyTVWidget> {
  final NativeTextFieldController _controller = NativeTextFieldController();

  @override
  void initState() {
    super.initState();
    
    // Add listener for text changes
    _controller.addListener(() {
      print('Text changed: ${_controller.text}');
      setState(() {
        // Update UI
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return NativeTextField(
      controller: _controller,
      hint: 'Enter text with TV remote...',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## 📚 API Reference

### NativeTextField

| Parameter | Type | Description |
|-----------|------|-------------|
| `hint` | `String?` | Hint text |
| `initialText` | `String?` | Initial text |
| `focusNode` | `FocusNode?` | Focus node for TV remote navigation |
| `onChanged` | `ValueChanged<String>?` | Text change callback |
| `onFocusChanged` | `ValueChanged<bool>?` | Focus change callback |
| `enabled` | `bool` | Whether the field is enabled, defaults to true |
| `width` | `double?` | Width of the field |
| `height` | `double?` | Height of the field |

### NativeTextFieldController

**Inherits from TextEditingController, providing all TextEditingController functionality:**

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `text` | `String` | Text content (inherited from TextEditingController) |
| `selection` | `TextSelection` | Text selection (inherited from TextEditingController) |
| `addListener(VoidCallback listener)` | `void` | Add listener (inherited from TextEditingController) |
| `removeListener(VoidCallback listener)` | `void` | Remove listener (inherited from TextEditingController) |
| `clear()` | `void` | Clear text (inherited from TextEditingController) |
| `setText(String text)` | `Future<void>` | Set text content |
| `getText()` | `Future<String>` | Get text content |
| `requestFocus()` | `Future<void>` | Request focus |
| `clearFocus()` | `Future<void>` | Clear focus |
| `setEnabled(bool enabled)` | `Future<void>` | Set enabled state |
| `setHint(String hint)` | `Future<void>` | Set hint text |
| `onFocusChanged` | `ValueChanged<bool>?` | Focus change callback |

## 🌐 Platform Support

- ✅ **Android** (TV and Mobile) - Uses PlatformView with native EditText
- ❌ iOS (Not implemented yet)
- ❌ Web (Not implemented yet)

## 🔧 Development Notes

This plugin uses Flutter's PlatformView mechanism to create native EditText components on Android. Communication between Flutter and native code is achieved through MethodChannel.

**Key Update:** NativeTextFieldController now inherits from TextEditingController, which means:

1. **Full Compatibility**: Can be used anywhere a TextEditingController is expected
2. **Synchronous Operations**: Supports synchronous text operations (e.g., `controller.text = 'new text'`)
3. **Listener Support**: Supports `addListener` and `removeListener`
4. **Auto-Sync**: Text changes automatically sync to native side
5. **Bidirectional Binding**: Native text changes also sync to Flutter side

### Why This Solution?

The [Flutter issue #154924](https://github.com/flutter/flutter/issues/154924) describes a problem where Flutter's default TextField doesn't work properly with TV remotes on Android TV devices. The keyboard appears but arrow key navigation through letters doesn't work because the Flutter app keeps focus.

This plugin provides a native Android solution that bypasses this limitation by using Android's native `EditText` component, which handles TV remote input correctly.

### Project Structure

```
lib/
├── native_textfield_tv.dart              # Main API
├── native_textfield_tv_platform_interface.dart  # 平台接口
└── native_textfield_tv_method_channel.dart      # 方法通道实现

android/src/main/kotlin/com/example/native_textfield_tv/
├── NativeTextfieldTvPlugin.kt            # Plugin main class
└── NativeTextfieldTvView.kt              # PlatformView implementation
```

## 🎮 TV Remote Control Usage

This plugin is specifically designed to work with Android TV remote controls. Here's how to use it effectively:

### Basic TV Remote Setup

```dart
class TVApp extends StatefulWidget {
  @override
  _TVAppState createState() => _TVAppState();
}

class _TVAppState extends State<TVApp> {
  final FocusNode _focusNode = FocusNode();
  final NativeTextFieldController _controller = NativeTextFieldController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              // This TextField works perfectly with TV remote!
              NativeTextField(
                controller: _controller,
                focusNode: _focusNode,
                hint: 'Use your TV remote to navigate and type',
                width: 400,
                height: 60,
                onChanged: (text) {
                  print('Text entered: $text');
                },
                onFocusChanged: (hasFocus) {
                  if (hasFocus) {
                    print('TextField focused - ready for remote input');
                  }
                },
              ),
              SizedBox(height: 20),
              Text('Current text: ${_controller.text}'),
            ],
          ),
        ),
      ),
    );
  }
}
```

### TV Remote Navigation Tips

1. **Focus Navigation**: Use the remote's arrow keys to navigate between UI elements
2. **Text Input**: When the TextField is focused, the on-screen keyboard will appear
3. **Character Selection**: Use arrow keys to navigate through keyboard letters
4. **Character Input**: Press the center/select button to input the selected character
5. **Text Editing**: Use the remote's back button to delete characters

### Compatibility

- ✅ **Android TV** (All versions)
- ✅ **Google Chromecast** (Solves the known input issue)
- ✅ **Fire TV** (Amazon Fire Stick)
- ✅ **NVIDIA Shield TV**
- ✅ **Other Android TV devices**

## 📄 License

MIT License
