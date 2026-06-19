# Keep Flutter Gemma plugin classes intact
-keep class com.denisovav.flutter_gemma.** { *; }

# Keep underlying LiteRT / TensorFlow Lite infrastructure bindings
-keep class org.tensorflow.lite.** { *; }
-keep class com.google.mediapipe.** { *; }

# Don't warn about missing reference lookups during optimization
-dontwarn com.denisovav.flutter_gemma.**
-dontwarn org.tensorflow.lite.**