/// Network timeouts
class NetworkTimeouts {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

/// Durations
class Durations {
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounce = Duration(milliseconds: 500);
  static const Duration throttle = Duration(milliseconds: 1000);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration shortDelay = Duration(milliseconds: 500);
  static const Duration mediumDelay = Duration(seconds: 1);
  static const Duration longDelay = Duration(seconds: 2);
}

/// Padding and spacing constants
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius constants
class BorderRadii {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double circle = 50.0;
}

/// Common numeric values
class CommonValues {
  static const int maxRetries = 3;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  static const int pageSize = 20;
}
