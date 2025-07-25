# native_textfield_tv

一个用于 Android TV 的原生文本输入框 Flutter 插件，支持 D-pad 导航。

## 特性

- 🎮 支持 Android TV D-pad 导航
- 📱 原生 Android EditText 实现
- 🔄 双向数据同步
- 🎯 焦点管理
- 🎨 可自定义样式
- 🔗 支持一个 Controller 管理多个文本框实例

## 设计理念

### instanceId 与 NativeTextField 绑定

每个 `NativeTextField` 实例都有自己唯一的 `instanceId`，这个 ID 用于在 Flutter 和原生 Android 之间进行通信。

### 一个 Controller 可以管理多个 instanceId

`NativeTextFieldController` 可以管理多个 `NativeTextField` 实例，实现以下功能：

- **数据同步**：当 controller 的文本发生变化时，所有关联的文本框都会同步更新
- **统一控制**：可以通过 controller 统一控制所有关联的文本框
- **资源管理**：controller 负责管理所有关联实例的生命周期

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  native_textfield_tv: ^1.0.0
```

## 使用方法

### 基本用法

```dart
import 'package:native_textfield_tv/native_textfield_tv.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final NativeTextFieldController _controller = NativeTextFieldController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return DpadNativeTextField(
      controller: _controller,
      focusNode: _focusNode,
      height: 48,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
```

### 共享 Controller 示例

```dart
class SharedControllerExample extends StatefulWidget {
  @override
  _SharedControllerExampleState createState() => _SharedControllerExampleState();
}

class _SharedControllerExampleState extends State<SharedControllerExample> {
  // 一个 controller 管理多个文本框
  final NativeTextFieldController _sharedController = NativeTextFieldController();
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 第一个文本框
        DpadNativeTextField(
          controller: _sharedController,
          focusNode: _focusNode1,
        ),
        SizedBox(height: 16),
        // 第二个文本框 - 共享同一个 controller
        DpadNativeTextField(
          controller: _sharedController,
          focusNode: _focusNode2,
        ),
        SizedBox(height: 16),
        // 控制按钮
        ElevatedButton(
          onPressed: () {
            _sharedController.setText('更新所有文本框');
          },
          child: Text('更新文本'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _sharedController.dispose();
    super.dispose();
  }
}
```

## API 参考

### NativeTextFieldController

控制器类，继承自 `TextEditingController`。

#### 构造函数

```dart
NativeTextFieldController({String? text})
```

#### 方法

- `Future<void> setText(String text)` - 设置文本
- `Future<String> getText()` - 获取文本
- `Future<void> requestFocus()` - 请求焦点
- `Future<void> clearFocus()` - 清除焦点
- `Future<void> setEnabled(bool enabled)` - 设置启用状态
- `Future<void> setHint(String hint)` - 设置提示文本
- `Future<void> moveCursorLeft()` - 向左移动光标
- `Future<void> moveCursorRight()` - 向右移动光标

### NativeTextField

原生文本输入框组件。

#### 属性

- `controller` - 控制器
- `hint` - 提示文本
- `initialText` - 初始文本
- `focusNode` - 焦点节点
- `onChanged` - 文本变化回调
- `onFocusChanged` - 焦点变化回调
- `enabled` - 是否启用
- `width` - 宽度
- `height` - 高度

### DpadNativeTextField

支持 D-pad 导航的文本输入框组件。

#### 属性

- `focusNode` - 焦点节点（必需）
- `controller` - 控制器（必需）
- `height` - 高度（默认 48）

## 键盘事件

支持以下键盘事件：

- `Arrow Left` - 向左移动光标
- `Arrow Right` - 向右移动光标
- `Select` - 确认选择

## 注意事项

1. **生命周期管理**：确保在 dispose 时正确释放 `FocusNode` 和 `NativeTextFieldController`
2. **焦点管理**：使用 `FocusNode` 来管理焦点状态
3. **数据同步**：controller 会自动同步所有关联文本框的数据
4. **资源清理**：controller 会自动管理所有关联实例的资源

## 示例

查看 `example/lib/main.dart` 获取完整的使用示例。

## 许可证

MIT License


