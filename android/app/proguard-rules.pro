# Keep all Google MediaPipe classes and inner proto classes
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Target the specific protobuf missing classes mentioned in the logs
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**
