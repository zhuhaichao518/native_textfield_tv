package com.example.native_textfield_tv

import android.content.Context
import android.graphics.Color
import android.text.Editable
import android.text.TextWatcher
import android.view.View
import android.widget.EditText
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class NativeTextfieldTvView(
    private val context: Context,
    private val viewId: Int,
    private val creationParams: Map<String?, Any?>?,
    private val messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    private val editText: EditText
    private val methodChannel: MethodChannel

    init {
        // 创建EditText
        editText = EditText(context).apply {
            // 设置基本样式
            setTextColor(Color.BLACK)
            setBackgroundColor(Color.WHITE)
            setPadding(16, 16, 16, 16)
            
            // 设置提示文本
            hint = creationParams?.get("hint") as? String ?: "请输入文本"
            
            // 设置初始文本
            val initialText = creationParams?.get("initialText") as? String
            if (initialText != null) {
                setText(initialText.toString())
            }
        }

        // 创建MethodChannel用于与Flutter通信
        methodChannel = MethodChannel(messenger, "native_textfield_tv_$viewId")
        methodChannel.setMethodCallHandler(this)

        // 添加文本变化监听器
        editText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            
            override fun afterTextChanged(s: Editable?) {
                // 通知Flutter文本已变化
                methodChannel.invokeMethod("onTextChanged", s.toString())
            }
        })

        // 设置焦点变化监听器
        editText.setOnFocusChangeListener { _, hasFocus ->
            methodChannel.invokeMethod("onFocusChanged", hasFocus)
        }
    }

    override fun getView(): View {
        return editText
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setText" -> {
                val text = call.argument<String>("text")
                editText.setText(text ?: "")
                result.success(null)
            }
            "getText" -> {
                result.success(editText.text.toString())
            }
            "requestFocus" -> {
                editText.requestFocus()
                result.success(null)
            }
            "clearFocus" -> {
                editText.clearFocus()
                result.success(null)
            }
            "setEnabled" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                editText.isEnabled = enabled
                result.success(null)
            }
            "setHint" -> {
                val hint = call.argument<String>("hint")
                editText.hint = hint
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
} 