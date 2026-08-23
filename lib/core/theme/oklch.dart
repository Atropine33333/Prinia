import 'dart:math' as math;
import 'dart:ui';

/// OKLCH 颜色空间转 sRGB。
///
/// 参考实现: https://bottosson.github.io/posts/oklab/
Color oklch(double lightness, double chroma, double hueDegrees,
    {double alpha = 1.0}) {
  final hueRad = hueDegrees * math.pi / 180;
  final a = chroma * math.cos(hueRad);
  final b = chroma * math.sin(hueRad);

  // OKLab -> LMS'
  final l_ = (lightness + 0.3963377774 * a + 0.2158037573 * b);
  final m_ = (lightness - 0.1055613458 * a - 0.0638541728 * b);
  final s_ = (lightness - 0.0894841775 * a - 1.2914855480 * b);

  // LMS' -> LMS (cubic)
  final l = l_ * l_ * l_;
  final m = m_ * m_ * m_;
  final s = s_ * s_ * s_;

  // LMS -> 线性 sRGB
  var rLin = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
  var gLin = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
  var bLin = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

  final r = _gammaEncode(rLin);
  final g = _gammaEncode(gLin);
  final bb = _gammaEncode(bLin);

  int to255(double v) => (v.clamp(0.0, 1.0) * 255).round();

  return Color.fromARGB(
    (alpha.clamp(0.0, 1.0) * 255).round(),
    to255(r),
    to255(g),
    to255(bb),
  );
}

double _gammaEncode(double c) {
  if (c <= 0) return 0;
  if (c >= 1) return 1;
  return c <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4) - 0.055;
}
