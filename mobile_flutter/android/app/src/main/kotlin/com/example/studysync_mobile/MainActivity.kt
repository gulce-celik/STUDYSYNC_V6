package com.example.studysync_mobile

import android.content.Context
import android.view.View
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val keyboardChannel = "com.example.studysync_mobile/keyboard"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, keyboardChannel).setMethodCallHandler { call, result ->
            if (call.method == "showSoftKeyboard") {
                val decor = window?.decorView
                if (decor != null) {
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                    fun tryShow() {
                        val focus: View? = currentFocus
                        if (focus != null) {
                            imm.restartInput(focus)
                            imm.showSoftInput(focus, InputMethodManager.SHOW_IMPLICIT)
                        } else {
                            val root = decor.rootView
                            imm.showSoftInput(root, InputMethodManager.SHOW_IMPLICIT)
                        }
                    }
                    decor.post {
                        tryShow()
                        // Flutter odak → Android currentFocus gecikmesi (özellikle emülatör)
                        decor.postDelayed({ tryShow() }, 120)
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
