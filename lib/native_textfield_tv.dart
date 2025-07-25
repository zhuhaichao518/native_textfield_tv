// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'native_textfield_tv_platform_interface.dart';

class NativeTextfieldTv {
  Future<String?> getPlatformVersion() {
    return NativeTextfieldTvPlatform.instance.getPlatformVersion();
  }
}

class NativeTextFieldController extends TextEditingController {
  static const MethodChannel _channel = MethodChannel('native_textfield_tv');
  
  // 存储所有活跃的控制器实例，用于处理回调
  static final Map<int, NativeTextFieldController> _instances = {};
  static int _nextInstanceId = 0;
  
  final int _instanceId;
  ValueChanged<bool>? onFocusChanged;
  bool _isUpdatingFromNative = false;

  NativeTextFieldController({String? text}) : _instanceId = _nextInstanceId++ {
    _instances[_instanceId] = this;
    if (text != null) {
      super.text = text;
    }
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    final instanceId = call.arguments['instanceId'] as int?;
    final controller = _instances[instanceId];
    
    if (controller == null) return;
    
    switch (call.method) {
      case 'onTextChanged':
        final text = call.arguments['text'] as String? ?? '';
        controller._isUpdatingFromNative = true;
        if (controller.text != text) {
          controller.text = text;
        }
        controller._isUpdatingFromNative = false;
        break;
      case 'onFocusChanged':
        final hasFocus = call.arguments['hasFocus'] as bool? ?? false;
        controller.onFocusChanged?.call(hasFocus);
        break;
    }
  }

  static void _initializeChannel() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    // 只有当不是从原生端更新时才同步到原生端
    if (!_isUpdatingFromNative) {
      _syncToNative();
    }
  }

  void _syncToNative() {
    _channel.invokeMethod('setText', {
      'instanceId': _instanceId,
      'text': text,
    });
  }

  Future<void> setText(String text) async {
    // 直接设置文本，notifyListeners 会自动同步到原生端
    this.text = text;
  }

  Future<String> getText() async {
    final result = await _channel.invokeMethod('getText', {
      'instanceId': _instanceId,
    });
    return result ?? '';
  }

  Future<void> requestFocus() async {
    await _channel.invokeMethod('requestFocus', {
      'instanceId': _instanceId,
    });
  }

  Future<void> clearFocus() async {
    await _channel.invokeMethod('clearFocus', {
      'instanceId': _instanceId,
    });
  }

  Future<void> setEnabled(bool enabled) async {
    await _channel.invokeMethod('setEnabled', {
      'instanceId': _instanceId,
      'enabled': enabled,
    });
  }

  Future<void> setHint(String hint) async {
    await _channel.invokeMethod('setHint', {
      'instanceId': _instanceId,
      'hint': hint,
    });
  }

  Future<void> moveCursorLeft() async {
    await _channel.invokeMethod('moveCursor', {
      'instanceId': _instanceId,
      'direction': 'left',
    });
  }

  Future<void> moveCursorRight() async {
    await _channel.invokeMethod('moveCursor', {
      'instanceId': _instanceId,
      'direction': 'right',
    });
  }

  @override
  void dispose() {
    _instances.remove(_instanceId);
    if (_instances.isEmpty) {
      _channel.setMethodCallHandler(null);
    }
    super.dispose();
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
  late NativeTextFieldController _controller;
  bool _isControllerCreated = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = NativeTextFieldController();
      _isControllerCreated = true;
    }
    
    // 设置回调
    if (widget.onChanged != null) {
      _controller.addListener(() {
        widget.onChanged!(_controller.text);
      });
    }
    _controller.onFocusChanged = widget.onFocusChanged;
    
    // 初始化 channel（只在第一次时）
    NativeTextFieldController._initializeChannel();
  }

  @override
  void didUpdateWidget(NativeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null && widget.controller != null) {
        _controller = widget.controller!;
        _isControllerCreated = false;
      } else if (oldWidget.controller != null && widget.controller == null) {
        _controller = NativeTextFieldController();
        _isControllerCreated = true;
      }
      
      // 重新设置回调
      if (widget.onChanged != null) {
        _controller.addListener(() {
          widget.onChanged!(_controller.text);
        });
      }
      _controller.onFocusChanged = widget.onFocusChanged;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'instanceId': _controller._instanceId,
      'hint': widget.hint,
      'initialText': widget.initialText,
    };

    Widget child = AndroidView(
      viewType: 'native_textfield_tv',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );

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
    // 可以在这里进行一些初始化操作
  }

  @override
  void dispose() {
    if (_isControllerCreated) {
      _controller.dispose();
    }
    super.dispose();
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
  final double height;

  const DpadNativeTextField({
    super.key,
    required this.focusNode,
    required this.controller,
    this.height = 48,
  });

  @override
  State<DpadNativeTextField> createState() => _DpadNativeTextFieldState();
}

class _DpadNativeTextFieldState extends State<DpadNativeTextField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        if (widget.focusNode.hasFocus) {
          widget.controller.requestFocus();
        } else {
          widget.controller.clearFocus();
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
          switch (event.logicalKey.keyLabel) {
            case keyLeft:
              widget.controller.moveCursorLeft();
              break;
            case keyRight:
              widget.controller.moveCursorRight();
              break;
          }
        }
      },
      child: NativeTextField(
        controller: widget.controller,
        width: double.infinity,
        height: widget.height,
      ),
    );
  }
}