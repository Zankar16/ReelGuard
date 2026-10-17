package com.example.reelguard

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.view.accessibility.AccessibilityEvent
import android.os.SystemClock

class ReelGuardAccessibilityService : AccessibilityService() {
  private var lastBlockedAt = 0L
  override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
    val packageName = event.packageName?.toString() ?: return
    if (packageName == this.packageName) return
    val prefs = getSharedPreferences("reelguard", Context.MODE_PRIVATE)
    if (!prefs.getBoolean("enabled", false)) return
    val blocked = prefs.getStringSet("packages", emptySet<String>()) ?: emptySet<String>()
    if (packageName !in blocked) return
    // Avoid repeatedly sending HOME while Android reports several window changes.
    val now = SystemClock.elapsedRealtime()
    if (now - lastBlockedAt < 1500) return
    lastBlockedAt = now
    performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
  }
  override fun onInterrupt() {}
}
