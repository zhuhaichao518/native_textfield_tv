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

  // 存储该 controller 管理的所有 instanceId
  final Set<int> _managedInstanceIds = {};
  ValueChanged<bool>? onFocusChanged;
  bool _isUpdatingFromNative = false;

  NativeTextFieldController({String? text}) {
    if (text != null) {
      super.text = text;
    }
  }

  // 注册一个新的 instanceId 到当前 controller
  int _registerInstance() {
    final instanceId = _nextInstanceId++;
    _managedInstanceIds.add(instanceId);
    _instances[instanceId] = this;
    return instanceId;
  }

  // 注销一个 instanceId
  void _unregisterInstance(int instanceId) {
    _managedInstanceIds.remove(instanceId);
    _instances.remove(instanceId);
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
    // 只有当不是从原生端更新时才同步到所有管理的实例
    if (!_isUpdatingFromNative) {
      _syncToAllNativeInstances();
    }
  }

  void _syncToAllNativeInstances() {
    for (final instanceId in _managedInstanceIds) {
      _channel.invokeMethod('setText', {
        'instanceId': instanceId,
        'text': text,
      });
    }
  }

  Future<void> setText(String text) async {
    this.text = text;
  }

  Future<String> getText() async {
    // 如果有管理的实例，从第一个实例获取文本
    if (_managedInstanceIds.isNotEmpty) {
      final firstInstanceId = _managedInstanceIds.first;
      final result = await _channel.invokeMethod('getText', {
        'instanceId': firstInstanceId,
      });
      return result ?? '';
    }
    return text;
  }

  Future<void> requestFocus() async {
    // 请求第一个实例的焦点
    if (_managedInstanceIds.isNotEmpty) {
      final firstInstanceId = _managedInstanceIds.first;
      await _channel.invokeMethod('requestFocus', {
        'instanceId': firstInstanceId,
      });
    }
  }

  Future<void> clearFocus() async {
    // 清除所有实例的焦点
    for (final instanceId in _managedInstanceIds) {
      await _channel.invokeMethod('clearFocus', {
        'instanceId': instanceId,
      });
    }
  }

  Future<void> setEnabled(bool enabled) async {
    // 设置所有实例的启用状态
    for (final instanceId in _managedInstanceIds) {
      await _channel.invokeMethod('setEnabled', {
        'instanceId': instanceId,
        'enabled': enabled,
      });
    }
  }

  Future<void> setHint(String hint) async {
    // 设置所有实例的提示文本
    for (final instanceId in _managedInstanceIds) {
      await _channel.invokeMethod('setHint', {
        'instanceId': instanceId,
        'hint': hint,
      });
    }
  }

  Future<void> moveCursorLeft() async {
    // 移动第一个实例的光标
    if (_managedInstanceIds.isNotEmpty) {
      final firstInstanceId = _managedInstanceIds.first;
      await _channel.invokeMethod('moveCursor', {
        'instanceId': firstInstanceId,
        'direction': 'left',
      });
    }
  }

  Future<void> moveCursorRight() async {
    // 移动第一个实例的光标
    if (_managedInstanceIds.isNotEmpty) {
      final firstInstanceId = _managedInstanceIds.first;
      await _channel.invokeMethod('moveCursor', {
        'instanceId': firstInstanceId,
        'direction': 'right',
      });
    }
  }

  @override
  void dispose() {
    // 清理所有管理的实例
    for (final instanceId in _managedInstanceIds.toList()) {
      _unregisterInstance(instanceId);
    }
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
  late int _instanceId;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = NativeTextFieldController();
      _isControllerCreated = true;
    }

    // 注册实例并获取 instanceId
    _instanceId = _controller._registerInstance();

    // 设置回调
    if (widget.onChanged != null) {
      _controller.addListener(() {
        widget.onChanged!(_controller.text);
      });
    }
    _controller.onFocusChanged = widget.onFocusChanged;

    NativeTextFieldController._initializeChannel();
  }

  @override
  void didUpdateWidget(NativeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // 注销旧的实例
      _controller._unregisterInstance(_instanceId);
      
      if (oldWidget.controller == null && widget.controller != null) {
        _controller = widget.controller!;
        _isControllerCreated = false;
      } else if (oldWidget.controller != null && widget.controller == null) {
        _controller = NativeTextFieldController();
        _isControllerCreated = true;
      }

      // 注册新的实例
      _instanceId = _controller._registerInstance();

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
      'instanceId': _instanceId,
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

    return child;
  }

  void _onPlatformViewCreated(int id) {}

  @override
  void dispose() {
    // 注销实例
    _controller._unregisterInstance(_instanceId);
    
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
