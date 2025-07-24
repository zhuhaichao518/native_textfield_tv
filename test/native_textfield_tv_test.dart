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

  test('NativeTextFieldController methods', () async {
    final controller = NativeTextFieldController();

    await controller.setText('new text');
    expect(log, hasLength(1));
    expect(log.first.method, 'setText');
    expect(log.first.arguments['text'], 'new text');
    expect(log.first.arguments['instanceId'], isNotNull);

    log.clear();

    final text = await controller.getText();
    expect(text, 'test text');
    expect(log, hasLength(1));
    expect(log.first.method, 'getText');
    expect(log.first.arguments['instanceId'], isNotNull);

    log.clear();

    await controller.requestFocus();
    expect(log, hasLength(1));
    expect(log.first.method, 'requestFocus');
    expect(log.first.arguments['instanceId'], isNotNull);

    log.clear();

    await controller.clearFocus();
    expect(log, hasLength(1));
    expect(log.first.method, 'clearFocus');
    expect(log.first.arguments['instanceId'], isNotNull);

    log.clear();

    await controller.setEnabled(false);
    expect(log, hasLength(1));
    expect(log.first.method, 'setEnabled');
    expect(log.first.arguments['enabled'], false);
    expect(log.first.arguments['instanceId'], isNotNull);

    log.clear();

    await controller.setHint('new hint');
    expect(log, hasLength(1));
    expect(log.first.method, 'setHint');
    expect(log.first.arguments['hint'], 'new hint');
    expect(log.first.arguments['instanceId'], isNotNull);
  });
}
