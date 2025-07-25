# Native TextField TV 使用指南

## 设计理念

### 问题分析

在原始设计中，`instanceId` 与 `NativeTextFieldController` 绑定，这导致了以下问题：

1. **一对一绑定限制**：一个 controller 只能对应一个文本框实例
2. **资源管理复杂**：无法在多个文本框中共享同一个 controller
3. **灵活性不足**：无法实现数据同步和统一控制

### 新的设计

#### instanceId 与 NativeTextField 绑定

每个 `NativeTextField` 实例都有自己唯一的 `instanceId`：

```dart
class _NativeTextFieldState extends State<NativeTextField> {
  late int _instanceId;
  
  @override
  void initState() {
    super.initState();
    // 注册实例并获取 instanceId
    _instanceId = _controller._registerInstance();
  }
}
```

#### 一个 Controller 管理多个 instanceId

`NativeTextFieldController` 现在可以管理多个 `instanceId`：

```dart
class NativeTextFieldController extends TextEditingController {
  // 存储该 controller 管理的所有 instanceId
  final Set<int> _managedInstanceIds = {};
  
  // 注册一个新的 instanceId 到当前 controller
  int _registerInstance() {
    final instanceId = _nextInstanceId++;
    _managedInstanceIds.add(instanceId);
    _instances[instanceId] = this;
    return instanceId;
  }
}
```

## 使用场景

### 1. 基本用法 - 一对一绑定

```dart
class BasicExample extends StatefulWidget {
  @override
  _BasicExampleState createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  final NativeTextFieldController _controller = NativeTextFieldController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return DpadNativeTextField(
      controller: _controller,
      focusNode: _focusNode,
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

### 2. 共享 Controller - 一对多绑定

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
  final FocusNode _focusNode3 = FocusNode();

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
        // 第三个文本框 - 也共享同一个 controller
        DpadNativeTextField(
          controller: _sharedController,
          focusNode: _focusNode3,
        ),
        SizedBox(height: 16),
        // 控制按钮 - 会影响所有文本框
        ElevatedButton(
          onPressed: () {
            _sharedController.setText('更新所有文本框');
          },
          child: Text('更新所有文本框'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _sharedController.dispose();
    super.dispose();
  }
}
```

### 3. 混合使用 - 共享和独立 Controller

```dart
class MixedExample extends StatefulWidget {
  @override
  _MixedExampleState createState() => _MixedExampleState();
}

class _MixedExampleState extends State<MixedExample> {
  // 共享的 controller
  final NativeTextFieldController _sharedController = NativeTextFieldController();
  
  // 独立的 controller
  final NativeTextFieldController _independentController = NativeTextFieldController();
  
  final FocusNode _sharedFocus1 = FocusNode();
  final FocusNode _sharedFocus2 = FocusNode();
  final FocusNode _independentFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('共享 Controller 的文本框:'),
        DpadNativeTextField(
          controller: _sharedController,
          focusNode: _sharedFocus1,
        ),
        DpadNativeTextField(
          controller: _sharedController,
          focusNode: _sharedFocus2,
        ),
        SizedBox(height: 16),
        Text('独立 Controller 的文本框:'),
        DpadNativeTextField(
          controller: _independentController,
          focusNode: _independentFocus,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _sharedController.setText('更新共享文本框');
              },
              child: Text('更新共享'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                _independentController.setText('更新独立文本框');
              },
              child: Text('更新独立'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sharedFocus1.dispose();
    _sharedFocus2.dispose();
    _independentFocus.dispose();
    _sharedController.dispose();
    _independentController.dispose();
    super.dispose();
  }
}
```

## 数据同步机制

### 从 Controller 到 NativeTextField

当 controller 的文本发生变化时，所有关联的文本框都会同步更新：

```dart
void _syncToAllNativeInstances() {
  for (final instanceId in _managedInstanceIds) {
    _channel.invokeMethod('setText', {
      'instanceId': instanceId,
      'text': text,
    });
  }
}
```

### 从 NativeTextField 到 Controller

当原生文本框的文本发生变化时，会通知 controller：

```dart
// 在 NativeTextfieldTvView.kt 中
editText.addTextChangedListener(object : TextWatcher {
  override fun afterTextChanged(s: Editable?) {
    methodChannel.invokeMethod("onTextChanged", mapOf(
      "instanceId" to instanceId,
      "text" to s.toString()
    ))
  }
})
```

## 资源管理

### 实例注册和注销

```dart
// 注册实例
int _registerInstance() {
  final instanceId = _nextInstanceId++;
  _managedInstanceIds.add(instanceId);
  _instances[instanceId] = this;
  return instanceId;
}

// 注销实例
void _unregisterInstance(int instanceId) {
  _managedInstanceIds.remove(instanceId);
  _instances.remove(instanceId);
}
```

### 生命周期管理

```dart
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
```

## 最佳实践

### 1. 合理使用共享 Controller

- **适用场景**：需要数据同步的多个文本框
- **不适用场景**：需要独立控制的文本框

### 2. 正确管理生命周期

```dart
@override
void dispose() {
  // 先释放 FocusNode
  _focusNode.dispose();
  // 再释放 Controller
  _controller.dispose();
  super.dispose();
}
```

### 3. 避免内存泄漏

- 确保在 dispose 时正确释放所有资源
- 避免在 controller 中持有对 widget 的强引用

### 4. 性能考虑

- 共享 controller 时，文本变化会同步到所有关联实例
- 对于大量文本框，考虑使用独立的 controller

## 常见问题

### Q: 为什么需要 instanceId？

A: instanceId 用于在 Flutter 和原生 Android 之间唯一标识每个文本框实例，确保正确的通信。

### Q: 一个 controller 可以管理多少个文本框？

A: 理论上没有限制，但建议根据实际需求合理使用，避免性能问题。

### Q: 如何实现文本框之间的数据同步？

A: 使用同一个 controller 即可实现自动数据同步。

### Q: 如何处理焦点管理？

A: 每个文本框使用独立的 FocusNode，controller 提供统一的焦点控制方法。 