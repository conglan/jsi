# Add project specific ProGuard rules here.
-keep class com.getcapacitor.** { *; }
-keep class com.jsi.app.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.getcapacitor.**
-dontwarn com.jsi.app.**
