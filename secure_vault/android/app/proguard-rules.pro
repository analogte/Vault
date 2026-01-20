# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter embedding
-keep class io.flutter.embedding.** { *; }

# Crypto libraries - Keep encryption related classes
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }
-keep class org.bouncycastle.** { *; }

# SQLite
-keep class org.sqlite.** { *; }
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.* { *; }

# Keep Parcelable classes
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Remove debug logs in release
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}

# Kotlin specific
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Biometric authentication
-keep class androidx.biometric.** { *; }

# File picker and image picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }

# Path provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Local auth (biometrics)
-keep class io.flutter.plugins.localauth.** { *; }

# Secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# SQFlite
-keep class com.tekartik.sqflite.** { *; }

# Google Play Core (for deferred components and app updates)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ========== Security Enhancement Rules ==========

# Flutter Jailbreak Detection
-keep class com.example.flutter_jailbreak_detection.** { *; }
-dontwarn com.example.flutter_jailbreak_detection.**

# Safe Device
-keep class com.pir.safedevice.** { *; }
-dontwarn com.pir.safedevice.**

# HashLib (Argon2id)
-keep class hashlib.** { *; }
-dontwarn hashlib.**

# Obfuscation settings for security
# Rename classes/methods to make reverse engineering harder
-repackageclasses 'o'
-allowaccessmodification
-overloadaggressively

# Encrypt string constants (additional security)
# Note: Full string encryption requires R8 full mode

# Remove source file info for additional obfuscation
-renamesourcefileattribute SourceFile

# Aggressive optimization
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5

# Security: Remove reflection calls in release
-assumenosideeffects class java.lang.reflect.Field {
    public java.lang.Object get(java.lang.Object);
    public void set(java.lang.Object, java.lang.Object);
}

# Prevent reverse engineering of security classes
-keep class com.securevault.secure_vault.MainActivity { *; }
-keepclassmembers class com.securevault.secure_vault.** {
    native <methods>;
}
