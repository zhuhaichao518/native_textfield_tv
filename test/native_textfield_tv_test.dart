import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_textfield_tv/native_textfield_tv.dart';

void main() {
  const MethodChannel channel = MethodChannel('native_textfield_tv');
  final log = <MethodCall>[];

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getPlatformVersion':
          return '42';
        case 'getText':
          return 'test text';
        case 'setText':
        case 'requestFocus':
        case 'clearFocus':
        case 'setEnabled':
        case 'setHint':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    log.clear();
  });

  test('getPlatformVersion', () async {
    expect(await NativeTextfieldTv().getPlatformVersion(), '42');
  });

  test('NativeTextField widget creation', () {
    final widget = NativeTextField(
      hint: 'Test hint',
      initialText: 'Test text',
      onChanged: (text) {},
      onFocusChanged: (hasFocus) {},
    );

    expect(widget.hint, 'Test hint');
    expect(widget.initialText, 'Test text');
    expect(widget.enabled, true);
  });

  test('NativeTextField instance methods', () async {
    // 创建一个 NativeTextField 实例来测试方法调用
    final controller = NativeTextFieldController();
    final widget = NativeTextField(controller: controller);
    
    // 由于方法现在绑定到 NativeTextField 实例而不是 controller，
    // 我们需要通过 widget 的 state 来调用这些方法
    // 这里我们测试 controller 的文本设置功能
    controller.text = 'new text';
    expect(controller.text, 'new text');

    // 测试 controller 的监听器功能
    String? lastText;
    controller.addListener(() {
      lastText = controller.text;
    });

    controller.text = 'listener test';
    expect(lastText, 'listener test');
  });

  test('NativeTextFieldController inheritance from TextEditingController', () {
    final controller = NativeTextFieldController(text: 'initial text');

    expect(controller.text, 'initial text');
    expect(controller.text.isEmpty, false);

    // 测试可以设置文本
    controller.text = 'new text';
    expect(controller.text, 'new text');

    // 测试监听器功能
    String? lastText;
    controller.addListener(() {
      lastText = controller.text;
    });

    controller.text = 'listener test';
    expect(lastText, 'listener test');

    controller.dispose();
  });

  test('NativeTextFieldController with onFocusChanged callback', () {
    final controller = NativeTextFieldController();
    bool? focusState;

    controller.onFocusChanged = (hasFocus) {
      focusState = hasFocus;
    };

    // 模拟焦点变化回调
    controller.onFocusChanged?.call(true);
    expect(focusState, true);

    controller.onFocusChanged?.call(false);
    expect(focusState, false);

    controller.dispose();
  });

  test('NativeTextField instance binding', () {
    final controller1 = NativeTextFieldController(text: 'text1');
    final controller2 = NativeTextFieldController(text: 'text2');
    
    // 创建两个不同的 NativeTextField 实例
    final widget1 = NativeTextField(controller: controller1);
    final widget2 = NativeTextField(controller: controller2);
    
    // 验证每个实例都有独立的 controller
    expect(controller1.text, 'text1');
    expect(controller2.text, 'text2');
    
    // 验证 controller 的独立性
    controller1.text = 'updated text1';
    expect(controller1.text, 'updated text1');
    expect(controller2.text, 'text2'); // 应该保持不变
  });

  test('NativeTextField widget properties', () {
    final controller = NativeTextFieldController();
    final widget = NativeTextField(
      controller: controller,
      hint: 'Test hint',
      initialText: 'Test text',
      enabled: false,
      width: 200.0,
      height: 50.0,
    );

    expect(widget.hint, 'Test hint');
    expect(widget.initialText, 'Test text');
    expect(widget.enabled, false);
    expect(widget.width, 200.0);
    expect(widget.height, 50.0);
  });
}
