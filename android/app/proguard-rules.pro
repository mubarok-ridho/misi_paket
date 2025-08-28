# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep all Dart generated code
-keep class * extends io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }

# Keep Firebase (kalau dipakai)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep OkHttp (kalau dipakai)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep Retrofit/Gson (kalau pakai API JSON)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep biometric auth (karena kamu pakai USE_BIOMETRIC)
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# Keep AndroidX Core
-keep class androidx.core.** { *; }
-dontwarn androidx.core.**
