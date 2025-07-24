import 'package:flutter_test/flutter_test.dart';
import 'package:native_textfield_tv/native_textfield_tv.dart';
import 'package:native_textfield_tv/native_textfield_tv_platform_interface.dart';
import 'package:native_textfield_tv/native_textfield_tv_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeTextfieldTvPlatform
    with MockPlatformInterfaceMixin
    implements NativeTextfieldTvPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeTextfieldTvPlatform initialPlatform = NativeTextfieldTvPlatform.instance;

  test('$MethodChannelNativeTextfieldTv is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeTextfieldTv>());
  });

  test('getPlatformVersion', () async {
    NativeTextfieldTv nativeTextfieldTvPlugin = NativeTextfieldTv();
    MockNativeTextfieldTvPlatform fakePlatform = MockNativeTextfieldTvPlatform();
    NativeTextfieldTvPlatform.instance = fakePlatform;

    expect(await nativeTextfieldTvPlugin.getPlatformVersion(), '42');
  });
}
