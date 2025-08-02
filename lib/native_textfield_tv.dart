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
  ValueChanged<bool>? onFocusChanged;
  bool _isUpdatingFromNative = false;

  NativeTextFieldController({String? text}) {
    if (text != null) {
      super.text = text;
    }
  }

  void _setTextFromNative(String text) {
    _isUpdatingFromNative = true;
    if (this.text != text) {
      this.text = text;
    }
    _isUpdatingFromNative = false;
  }

  bool get isUpdatingFromNative => _isUpdatingFromNative;

  Future<void> setText(String text) async {
    this.text = text;
  }

  @override
  void dispose() {
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
  final bool obscureText;
  final int? maxLines;

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
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  State<NativeTextField> createState() => _NativeTextFieldState();
}

class _NativeTextFieldState extends State<NativeTextField> {
  late NativeTextFieldController _controller;
  bool _isControllerCreated = false;
  late int _instanceId;
  static int _nextInstanceId = 0;
  static const MethodChannel _channel = MethodChannel('native_textfield_tv');
  static final Map<int, _NativeTextFieldState> _instances = {};

  @override
  void initState() {
    super.initState();
    _instanceId = _nextInstanceId++;
    _instances[_instanceId] = this;
    
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = NativeTextFieldController();
      _isControllerCreated = true;
    }

    // 设置回调
    if (widget.onChanged != null) {
      _controller.addListener(() {
        if (!_controller.isUpdatingFromNative) {
          widget.onChanged!(_controller.text);
        }
      });
    }
    _controller.onFocusChanged = widget.onFocusChanged;

    // 监听 controller 的文本变化，同步到原生端
    _controller.addListener(_onControllerTextChanged);

    _initializeChannel();
  }

  void _onControllerTextChanged() {
    if (!_controller.isUpdatingFromNative) {
      _syncToNative();
    }
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    final instanceId = call.arguments['instanceId'] as int?;
    final instance = _instances[instanceId];

    if (instance == null) return;

    switch (call.method) {
      case 'onTextChanged':
        final text = call.arguments['text'] as String? ?? '';
        instance._controller._setTextFromNative(text);
        break;
      case 'onFocusChanged':
        final hasFocus = call.arguments['hasFocus'] as bool? ?? false;
        instance._controller.onFocusChanged?.call(hasFocus);
        break;
    }
  }

  static void _initializeChannel() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  void _syncToNative() {
    _channel.invokeMethod('setText', {
      'instanceId': _instanceId,
      'text': _controller.text,
    });
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
  void didUpdateWidget(NativeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // 清理旧的监听器
      _controller.removeListener(_onControllerTextChanged);
      if (oldWidget.onChanged != null) {
        _controller.removeListener(() {
          oldWidget.onChanged!(_controller.text);
        });
      }
      
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
          if (!_controller.isUpdatingFromNative) {
            widget.onChanged!(_controller.text);
          }
        });
      }
      _controller.onFocusChanged = widget.onFocusChanged;
      _controller.addListener(_onControllerTextChanged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'instanceId': _instanceId,
      'hint': widget.hint,
      'initialText': widget.initialText,
      'obscureText': widget.obscureText,
      'maxLines': widget.maxLines,
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

    return child;
  }

  void _onPlatformViewCreated(int id) {
    // AndroidView 创建完成后，同步 controller 的当前文本到原生端
    // 如果 controller 有文本内容且与 initialText 不同，则同步到原生端
    if (_controller.text.isNotEmpty && 
        _controller.text != widget.initialText) {
      _syncToNative();
    }
  }

  @override
  void dispose() {
    _instances.remove(_instanceId);
    if (_instances.isEmpty) {
      _channel.setMethodCallHandler(null);
    }
    
    _controller.removeListener(_onControllerTextChanged);
    
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
  final bool obscureText;
  final String? hint;
  final int? maxLines;
  //final int? minLines;

  const DpadNativeTextField({
    super.key,
    required this.focusNode,
    required this.controller,
    this.height = 48,
    this.obscureText = false,
    this.hint,
    this.maxLines = 1,
    //this.minLines,
  });

  @override
  State<DpadNativeTextField> createState() => _DpadNativeTextFieldState();
}

class _DpadNativeTextFieldState extends State<DpadNativeTextField> {
  final GlobalKey<_NativeTextFieldState> _nativeTextFieldKey = GlobalKey<_NativeTextFieldState>();

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        if (widget.focusNode.hasFocus) {
          _nativeTextFieldKey.currentState?.requestFocus();
        } else {
          _nativeTextFieldKey.currentState?.clearFocus();
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
              _nativeTextFieldKey.currentState?.moveCursorLeft();
              break;
            case keyRight:
              _nativeTextFieldKey.currentState?.moveCursorRight();
              break;
          }
        }
      },
      child: NativeTextField(
        key: _nativeTextFieldKey,
        controller: widget.controller,
        width: double.infinity,
        height: widget.height,
        obscureText: widget.obscureText,
        hint: widget.hint,
        maxLines: widget.maxLines,
      ),
    );
  }
}
