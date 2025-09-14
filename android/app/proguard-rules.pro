# Flutter相关混淆规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart相关
-keep class dartx.** { *; }

# 网络请求相关
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Gson相关
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# 数据模型类（防止被混淆）
-keep class com.stockmonitor.app.models.** { *; }

# WorkManager相关
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keep class androidx.work.impl.WorkManagerInitializer

# 通知相关
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class com.dexterous.** { *; }

# SQLite相关
-keep class androidx.sqlite.** { *; }
-keep class androidx.room.** { *; }

# 反射相关
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 保持native方法
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保持自定义View
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
    *** get*();
}

# 保持Activity
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# 保持Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 保持Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 移除日志
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# 优化相关
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# 保持行号信息（用于调试崩溃）
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# 不混淆泛型
-keepattributes Signature

# 不混淆注解
-keepattributes *Annotation*

# 不警告缺失的类
-dontwarn javax.annotation.**
-dontwarn javax.inject.**
-dontwarn sun.misc.Unsafe
