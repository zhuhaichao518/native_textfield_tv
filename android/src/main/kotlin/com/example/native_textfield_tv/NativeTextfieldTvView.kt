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
) : PlatformView {

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
            
            // 设置密码模式
            val obscureText = creationParams?.get("obscureText") as? Boolean ?: false
            if (obscureText) {
                inputType = android.text.InputType.TYPE_CLASS_TEXT or android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD
            }

            val maxLines = creationParams?.get("maxLines") as? Int ?: 1
            setLines(maxLines)
        }

        // 使用统一的MethodChannel
        methodChannel = MethodChannel(messenger, "native_textfield_tv")

        // 添加文本变化监听器
        editText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            
            override fun afterTextChanged(s: Editable?) {
                // 通知Flutter文本已变化
                val instanceId = creationParams?.get("instanceId") as? Int
                methodChannel.invokeMethod("onTextChanged", mapOf(
                    "instanceId" to instanceId,
                    "text" to s.toString()
                ))
            }
        })

        // 设置焦点变化监听器
        editText.setOnFocusChangeListener { _, hasFocus ->
            val instanceId = creationParams?.get("instanceId") as? Int
            methodChannel.invokeMethod("onFocusChanged", mapOf(
                "instanceId" to instanceId,
                "hasFocus" to hasFocus
            ))
        }
    }

    override fun getView(): View {
        return editText
    }

    override fun dispose() {
        // 清理资源
    }

    // 添加必要的方法来支持 Flutter 端的调用
    fun setText(text: String) {
        editText.setText(text)
    }

    fun getText(): String {
        return editText.text.toString()
    }

    fun requestFocus() {
        editText.requestFocus()
    }

    fun clearFocus() {
        editText.clearFocus()
    }

    fun setEnabled(enabled: Boolean) {
        editText.isEnabled = enabled
    }

    fun setHint(hint: String?) {
        editText.hint = hint
    }

    fun moveCursor(direction: String) {
        val pos = editText.selectionStart
        when (direction) {
            "left" -> {
                if (pos > 0) {
                    editText.setSelection(pos - 1)
                }
            }
            "right" -> {
                if (pos < (editText.text?.length ?: 0)) {
                    editText.setSelection(pos + 1)
                }
            }
        }
    }
} 