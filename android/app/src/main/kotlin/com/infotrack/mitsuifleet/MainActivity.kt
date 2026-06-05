package com.infotrack.mitsuifleet

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    // Android 15+ (targetSdk 35) uses edge-to-edge by default.
    // Tell the system we'll handle insets from Flutter (SafeArea/MediaQuery).
    WindowCompat.setDecorFitsSystemWindows(window, false)
    super.onCreate(savedInstanceState)
  }
}

