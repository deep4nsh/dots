import 'package:flutter/material.dart';

/// A custom ink feature that provides a smooth, liquid-like ripple effect.
/// Since Material 3 already provides [InkSparkle] (which is liquid/noisy),
/// this stub can either return [InkRipple] (which is smooth and fluid)
/// or [InkSparkle] based on preference.
class LiquidRipple {
  static InteractiveInkFeatureFactory get splashFactory => InkRipple.splashFactory;
}
