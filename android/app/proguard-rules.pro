# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class com.google.android.material.** { *; }

# Preserve line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application classes
-keep class com.example.** { *; }

# Preserve enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserve Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Preserve Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# HTTP client
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# JSON serialization
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Retrofit
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Hive
-keep class hive.** { *; }
-keep class com.example.** { *; }

# SQLite
-keep class android.database.** { *; }

# Permission handler
-keep class com.baseflow.** { *; }
-dontwarn com.baseflow.**
