// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'native_textfield_tv_platform_interface.dart';

class NativeTextfieldTv {
  Future<String?> getPlatformVersion() {
    return NativeTextfieldTvPlatform.instance.getPlatformVersion();
  }
}

class NativeTextFieldController {
  MethodChannel? _channel;

  static int _nextViewId = 0;
  static int _getNextViewId() {
    return _nextViewId++;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChanged':
        //final text = call.arguments as String? ?? '';
        //widget.onChanged?.call(text);
        break;
      case 'onFocusChanged':
        //final hasFocus = call.arguments as bool? ?? false;
        //widget.onFocusChanged?.call(hasFocus);
        break;
    }
  }

  NativeTextFieldController() {
    int viewId = _getNextViewId();
    _channel = MethodChannel('native_textfield_tv_$viewId');
    _channel!.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> setText(String text) async {
    await _channel!.invokeMethod('setText', {'text': text});
  }

  Future<String> getText() async {
    final result = await _channel!.invokeMethod('getText');
    return result ?? '';
  }

  Future<void> requestFocus() async {
    await _channel!.invokeMethod('requestFocus');
  }

  Future<void> clearFocus() async {
    await _channel!.invokeMethod('clearFocus');
  }

  Future<void> setEnabled(bool enabled) async {
    await _channel!.invokeMethod('setEnabled', {'enabled': enabled});
  }

  Future<void> setHint(String hint) async {
    await _channel!.invokeMethod('setHint', {'hint': hint});
  }

  void dispose() {
    _channel!.setMethodCallHandler(null);
  }
}

/// NativeTextField Widget
class NativeTextField extends StatefulWidget {
  final NativeTextFieldController? controller;
  final String? hint;
  final String? initialText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChanged;
  final bool enabled;
  final double? width;
  final double? height;

  const NativeTextField({
    super.key,
    this.controller,
    this.hint,
    this.initialText,
    this.focusNode,
    this.onChanged,
    this.onFocusChanged,
    this.enabled = true,
    this.width,
    this.height,
  });

  @override
  State<NativeTextField> createState() => _NativeTextFieldState();
}

class _NativeTextFieldState extends State<NativeTextField> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'hint': widget.hint,
      'initialText': widget.initialText,
    };

    Widget child = AndroidView(
      viewType: 'native_textfield_tv',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );

    // 如果指定了尺寸，使用 SizedBox 包装
    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: child,
      );
    }

    // 否则直接返回 AndroidView，让它根据父级约束自适应
    return child;
  }

  void _onPlatformViewCreated(int id) {
    // PlatformView创建完成后的回调
  }
}

const String keyUp = 'Arrow Up';
const String keyDown = 'Arrow Down';
const String keyLeft = 'Arrow Left';
const String keyRight = 'Arrow Right';
const String keyCenter = 'Select';
const String goBack = 'Go Back';

class DpadNativeTextField extends StatefulWidget {
  final FocusNode focusNode;
  final NativeTextFieldController controller;

  const DpadNativeTextField({
    super.key,
    required this.focusNode,
    required this.controller,
  });

  @override
  State<DpadNativeTextField> createState() => _DpadNativeTextFieldState();
}

class _DpadNativeTextFieldState extends State<DpadNativeTextField> {
  // DpadTextField or textField has focus
  // TODO :use widget.focusNode.hasPrimaryFocus
  bool _wapperhasFocus = false;
  bool blockNextFocusChange = false;
  bool _textFieldhasFocus = false;

  @override
  void initState() {
    super.initState();
    _wapperhasFocus = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        if (widget.focusNode.hasFocus) {
          widget.controller.requestFocus();
          //_wapperhasFocus = widget.focusNode.hasFocus;
        } else {
          //_wapperhasFocus = widget.focusNode.hasFocus;
        }
        if (!_textFieldhasFocus && widget.focusNode.hasFocus) {
          //widget.focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: widget.focusNode,
      onKeyEvent: (event) {
        if (event is KeyUpEvent) {
          if (event.logicalKey.keyLabel == keyCenter && !_textFieldhasFocus) {
            //_textFieldhasFocus = true;
            //FocusScope.of(context).nextFocus();
          } else if (event.logicalKey.keyLabel == keyDown && !_textFieldhasFocus) {
            //_textFieldhasFocus = false;
          } else if (event.logicalKey.keyLabel == keyUp && !_textFieldhasFocus) {
            //_textFieldhasFocus = false;
          } else if (event.logicalKey.keyLabel == keyCenter && _textFieldhasFocus){
            //SystemChannels.textInput.invokeMethod('TextInput.show');
          } else if (event.logicalKey.keyLabel == keyUp && _textFieldhasFocus){
            //_textFieldhasFocus = false;
            //widget.focusNode.requestFocus();
          } else if (event.logicalKey.keyLabel == keyDown && _textFieldhasFocus){
            //_textFieldhasFocus = false;
            //widget.focusNode.requestFocus();
          }
        }
      },
      child: Container(
        decoration: _wapperhasFocus
            ? BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: NativeTextField(
          controller: widget.controller,
          width: double.infinity,
          height: 50,
        ),
      ),
    );
  }
}