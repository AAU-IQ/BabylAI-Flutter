# ProGuard rules for babylai_flutter plugin
# These rules are automatically applied to apps using this plugin

# Keep BabylAI SDK classes
-keep class iq.aau.babylai.** { *; }
-keepclassmembers class iq.aau.babylai.** { *; }

# Keep plugin classes
-keep class iq.aau.babylai_flutter.** { *; }

# Lombok - Don't warn about missing Lombok classes (compile-time only annotation processor)
-dontwarn lombok.**
-dontwarn lombok.Generated

# Ably Realtime SDK - Required for chat functionality
-keep class io.ably.** { *; }
-keepclassmembers class io.ably.** { *; }
-dontwarn io.ably.**

# MessagePack - Required by Ably for message serialization
-keep class org.msgpack.** { *; }
-keepclassmembers class org.msgpack.** { *; }
-dontwarn org.msgpack.**

# Java-WebSocket - Used by Ably
-keep class org.java_websocket.** { *; }
-keepclassmembers class org.java_websocket.** { *; }
-dontwarn org.java_websocket.**

# Retrofit - Network communication
-keepattributes Signature
-keepattributes Exceptions
-keepattributes *Annotation*
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}
-keep class retrofit2.** { *; }
-keepclassmembers class retrofit2.** { *; }

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Kotlin Serialization - Data parsing
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep serializers for BabylAI SDK models
-keep,includedescriptorclasses class iq.aau.babylai.**$$serializer { *; }
-keepclassmembers class iq.aau.babylai.** {
    *** Companion;
}
-keepclasseswithmembers class iq.aau.babylai.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Jetpack Compose - UI framework
-keep class androidx.compose.** { *; }
-keep interface androidx.compose.** { *; }
-dontwarn androidx.compose.**

# Lottie - Animations
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# Security - Encrypted SharedPreferences
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# SLF4J - Logging
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Keep Kotlin metadata for reflection
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Flutter Play Store Split / Deferred Components
# These are only needed if using deferred components feature
# Safe to suppress warnings if not using this feature
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep line numbers for debugging stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

