package com.securevault.secure_vault

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.securevault/security"
    private var screenshotPreventionEnabled = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Enable screenshot prevention by default
        enableScreenshotPrevention()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup method channel for Flutter communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableScreenshotPrevention" -> {
                    enableScreenshotPrevention()
                    result.success(true)
                }
                "disableScreenshotPrevention" -> {
                    disableScreenshotPrevention()
                    result.success(true)
                }
                "isScreenshotPreventionEnabled" -> {
                    result.success(screenshotPreventionEnabled)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun enableScreenshotPrevention() {
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
        screenshotPreventionEnabled = true
    }

    private fun disableScreenshotPrevention() {
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        screenshotPreventionEnabled = false
    }
}
