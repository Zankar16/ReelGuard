package com.example.reelguard

import android.content.Intent
import android.provider.Settings
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channel = "reelguard/blocker"
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
      when (call.method) {
        "setBlocking" -> {
          val enabled = call.argument<Boolean>("enabled") ?: false
          val packages = call.argument<List<String>>("packages") ?: emptyList()
          getSharedPreferences("reelguard", MODE_PRIVATE).edit()
            .putBoolean("enabled", enabled).putStringSet("packages", packages.toSet()).apply()
          result.success(true)
        }
        "openAccessibilitySettings" -> {
          startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
          result.success(true)
        }
        else -> result.notImplemented()
      }
    }
  }
}
