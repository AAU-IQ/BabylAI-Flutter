# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep BabylAI SDK classes
-keep class iq.aau.babylai.** { *; }
-keepclassmembers class iq.aau.babylai.** { *; }

# Lombok - Don't warn about missing Lombok classes (compile-time only)
-dontwarn lombok.**
-dontwarn lombok.Generated

# Ably Realtime SDK
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

# Retrofit
-keepattributes Signature
-keepattributes Exceptions
-keepattributes *Annotation*
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Kotlin Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}
-keep,includedescriptorclasses class iq.aau.babylai.**$$serializer { *; }
-keepclassmembers class iq.aau.babylai.** {
    *** Companion;
}
-keepclasseswithmembers class iq.aau.babylai.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep Compose classes
-keep class androidx.compose.** { *; }
-keep interface androidx.compose.** { *; }

# Keep Lottie classes
-keep class com.airbnb.lottie.** { *; }
-dontwarn com.airbnb.lottie.**

# Keep generic signature of Callbacks (needed for proper callback handling)
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Security - Encrypted SharedPreferences
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# SLF4J
-dontwarn org.slf4j.**
-keep class org.slf4j.** { *; }

# Keep Flutter plugin classes
-keep class io.flutter.** { *; }
-keep class iq.aau.babylai_flutter.** { *; }

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

# General Android rules
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

