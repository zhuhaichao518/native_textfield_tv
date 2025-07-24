// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/to/pubspec-plugin-platforms.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'native_textfield_tv_platform_interface.dart';

// 导出所有公共API
export 'native_textfield_tv_platform_interface.dart';

class NativeTextfieldTv {
  Future<String?> getPlatformVersion() {
    return NativeTextfieldTvPlatform.instance.getPlatformVersion();
  }
}

/// 控制器类，用于控制NativeTextField
class NativeTextFieldController {
  final int _viewId;
  final MethodChannel _channel;

  NativeTextFieldController(this._viewId, this._channel);

  /// 设置文本内容
  Future<void> setText(String text) async {
    await _channel.invokeMethod('setText', {'text': text});
  }

  /// 获取文本内容
  Future<String> getText() async {
    final result = await _channel.invokeMethod('getText');
    return result ?? '';
  }

  /// 请求焦点
  Future<void> requestFocus() async {
    await _channel.invokeMethod('requestFocus');
  }

  /// 清除焦点
  Future<void> clearFocus() async {
    await _channel.invokeMethod('clearFocus');
  }

  /// 设置是否启用
  Future<void> setEnabled(bool enabled) async {
    await _channel.invokeMethod('setEnabled', {'enabled': enabled});
  }

  /// 设置提示文本
  Future<void> setHint(String hint) async {
    await _channel.invokeMethod('setHint', {'hint': hint});
  }
}

/// NativeTextField Widget
class NativeTextField extends StatefulWidget {
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
  late MethodChannel _channel;
  int? _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = _getNextViewId();
    _channel = MethodChannel('native_textfield_tv_$_viewId');
    _controller = NativeTextFieldController(_viewId!, _channel);
    
    // 设置方法调用处理器
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    super.dispose();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextChanged':
        final text = call.arguments as String? ?? '';
        widget.onChanged?.call(text);
        break;
      case 'onFocusChanged':
        final hasFocus = call.arguments as bool? ?? false;
        widget.onFocusChanged?.call(hasFocus);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'hint': widget.hint,
      'initialText': widget.initialText,
    };

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AndroidView(
        viewType: 'native_textfield_tv',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    // PlatformView创建完成后的回调
    if (widget.focusNode != null) {
      widget.focusNode!.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (widget.focusNode?.hasFocus == true) {
      _controller.requestFocus();
    } else {
      _controller.clearFocus();
    }
  }

  static int _nextViewId = 0;
  static int _getNextViewId() {
    return _nextViewId++;
  }
}
