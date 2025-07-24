package com.example.native_textfield_tv

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.BinaryMessenger

/** NativeTextfieldTvPlugin */
class NativeTextfieldTvPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var messenger: BinaryMessenger
  
  // 存储所有活跃的 NativeTextfieldTvView 实例
  private val viewInstances = mutableMapOf<Int, NativeTextfieldTvView>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    messenger = flutterPluginBinding.binaryMessenger
    channel = MethodChannel(messenger, "native_textfield_tv")
    channel.setMethodCallHandler(this)
    
    // 注册PlatformViewFactory
    flutterPluginBinding
        .platformViewRegistry
        .registerViewFactory("native_textfield_tv", NativeTextfieldTvFactory(messenger, viewInstances))
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "setText" -> {
        val instanceId = call.argument<Int>("instanceId")
        val text = call.argument<String>("text")
        val view = viewInstances[instanceId]
        if (view != null) {
          view.setText(text ?: "")
          result.success(null)
        } else {
          result.error("INVALID_INSTANCE", "View instance not found", null)
        }
      }
      "getText" -> {
        val instanceId = call.argument<Int>("instanceId")
        val view = viewInstances[instanceId]
        if (view != null) {
          result.success(view.getText())
        } else {
          result.error("INVALID_INSTANCE", "View instance not found", null)
        }
      }
      "requestFocus" -> {
        val instanceId = call.argument<Int>("instanceId")
        val view = viewInstances[instanceId]
        if (view != null) {
          view.requestFocus()
          result.success(null)
        } else {
          result.error("INVALID_INSTANCE", "View instance not found", null)
        }
      }
      "clearFocus" -> {
        val instanceId = call.argument<Int>("instanceId")
        val view = viewInstances[instanceId]
        if (view != null) {
          view.clearFocus()
          result.success(null)
        } else {
          result.error("INVALID_INSTANCE", "View instance not found", null)
        }
      }
      "setEnabled" -> {
        val instanceId = call.argument<Int>("instanceId")
        val enabled = call.argument<Boolean>("enabled") ?: true
        val view = viewInstances[instanceId]
        if (view != null) {
          view.setEnabled(enabled)
          result.success(null)
        } else {
          result.error("INVALID_INSTANCE", "View instance not found", null)
        }
      }
      "setHint" -> {
        val instanceId = call.argument<Int>("instanceId")
        val hint = call.argument<String>("hint")
        val view = viewInstances[instanceId]
        if (view != null) {
          view.setHint(hint)
          result.success(null)
        } else {
          result.error("INVALID_INSTANCE", "View instance not found", null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    viewInstances.clear()
  }
}

class NativeTextfieldTvFactory(
    private val messenger: BinaryMessenger,
    private val viewInstances: MutableMap<Int, NativeTextfieldTvView>
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: android.content.Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as Map<String?, Any?>?
        val instanceId = creationParams?.get("instanceId") as? Int ?: viewId
        val view = NativeTextfieldTvView(context, viewId, creationParams, messenger)
        viewInstances[instanceId] = view
        return view
    }
} 