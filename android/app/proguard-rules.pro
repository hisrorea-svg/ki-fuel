# ProGuard Rules for Kirkuk Fuel Quota

# Keep generic signature of TypeToken (needed for Gson)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Gson specific rules to prevent TypeToken issues
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }
-keep class com.google.gson.** { *; }

# Specifically keep TypeToken and its subclasses to preserve generic types
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**
