-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class io.flutter.plugins.firebase.messaging.** { *; }

# Common R8 warnings sometimes seen with AndroidX sidecar/window.
-dontwarn androidx.window.**
-dontwarn androidx.window.extensions.**
