# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ARCore & Sceneform
-keep class com.google.ar.core.** { *; }
-keep class com.google.ar.sceneform.** { *; }
-dontwarn com.google.ar.sceneform.**

# Desugar
-dontwarn com.google.devtools.build.android.desugar.runtime.**
-keep class com.google.devtools.build.android.desugar.runtime.** { *; }

# AndroidX / Support
-keep class androidx.** { *; }
-keep class android.support.** { *; }
-dontwarn android.support.**

# Play Core (Deferred Components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
