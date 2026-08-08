# Razorpay Flutter — required ProGuard rules for release builds.
# Without these, payment checkout can crash/fail silently in release mode
# because ProGuard strips classes Razorpay's SDK reflects into at runtime.

-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/removal/parameter
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Google Pay / UPI intent related classes some banks' apps expect
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
