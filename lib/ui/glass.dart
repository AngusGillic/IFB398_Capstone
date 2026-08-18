import 'dart:ui';

import 'package:flutter/cupertino.dart';

abstract final class LGGap {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double edge = 16;
  static const double section = 20;
}

abstract final class LGRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 22;
  static const double xxl = 28;
  static const double pill = 999;
}

abstract final class LGMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve standard = Cubic(0.25, 0.1, 0.25, 1.0);
  static const Curve enter = Cubic(0.16, 1.0, 0.3, 1.0);
  static const Curve press = Curves.easeOutCubic;
}

abstract final class LGColor {
  static const CupertinoDynamicColor accent = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF007AFF),
    darkColor: Color(0xFF0A84FF),
  );

  static const CupertinoDynamicColor eco = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF34C759),
    darkColor: Color(0xFF30D158),
  );

  static const CupertinoDynamicColor effort = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF9500),
    darkColor: Color(0xFFFF9F0A),
  );

  static const CupertinoDynamicColor burn = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF3B30),
    darkColor: Color(0xFFFF453A),
  );

  static const CupertinoDynamicColor transit = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFAF52DE),
    darkColor: Color(0xFFBF5AF2),
  );

  static const CupertinoDynamicColor walk = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF32ADE6),
    darkColor: Color(0xFF64D2FF),
  );

  static const CupertinoDynamicColor warn = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFCC00),
    darkColor: Color(0xFFFFD60A),
  );

  static const CupertinoDynamicColor label = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF000000),
    darkColor: Color(0xFFFFFFFF),
  );

  static const CupertinoDynamicColor secondaryLabel = CupertinoDynamicColor.withBrightness(
    color: Color(0x993C3C43),
    darkColor: Color(0x99EBEBF5),
  );

  static const CupertinoDynamicColor tertiaryLabel = CupertinoDynamicColor.withBrightness(
    color: Color(0x4D3C3C43),
    darkColor: Color(0x4DEBEBF5),
  );

  static const CupertinoDynamicColor canvas = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2F2F7),
    darkColor: Color(0xFF000000),
  );

  static const CupertinoDynamicColor grouped = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF1C1C1E),
  );

  static const CupertinoDynamicColor separator = CupertinoDynamicColor.withBrightness(
    color: Color(0x4D3C3C43),
    darkColor: Color(0x4D545458),
  );

  static const CupertinoDynamicColor fill = CupertinoDynamicColor.withBrightness(
    color: Color(0x1E787880),
    darkColor: Color(0x28787880),
  );

  static const CupertinoDynamicColor glassTint = CupertinoDynamicColor.withBrightness(
    color: Color(0xB8FFFFFF),
    darkColor: Color(0x8A1C1C1E),
  );

  static const CupertinoDynamicColor glassTintDense = CupertinoDynamicColor.withBrightness(
    color: Color(0xD6FFFFFF),
    darkColor: Color(0xB82C2C2E),
  );

  static const CupertinoDynamicColor glassRimBright = CupertinoDynamicColor.withBrightness(
    color: Color(0x8FFFFFFF),
    darkColor: Color(0x4DFFFFFF),
  );

  static const CupertinoDynamicColor glassRimDim = CupertinoDynamicColor.withBrightness(
    color: Color(0x1F000000),
    darkColor: Color(0x1AFFFFFF),
  );

  static Color resolve(CupertinoDynamicColor c, BuildContext context) =>
      CupertinoDynamicColor.resolve(c, context);
}

abstract final class LGShadow {
  static List<BoxShadow> low(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, dark ? 0.28 : 0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> floating(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, dark ? 0.38 : 0.08),
        blurRadius: 16,
        spreadRadius: -2,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, dark ? 0.20 : 0.03),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }
}

abstract final class LGText {
  static TextStyle _base(BuildContext context) =>
      CupertinoTheme.of(context).textTheme.textStyle;

  static TextStyle largeTitle(BuildContext context) => _base(context).copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.37,
        height: 1.2,
      );

  static TextStyle title1(BuildContext context) => _base(context).copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.36,
        height: 1.21,
      );

  static TextStyle title2(BuildContext context) => _base(context).copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
        height: 1.27,
      );

  static TextStyle title3(BuildContext context) => _base(context).copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.38,
        height: 1.25,
      );

  static TextStyle headline(BuildContext context) => _base(context).copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        height: 1.29,
      );

  static TextStyle body(BuildContext context) => _base(context).copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        height: 1.29,
      );

  static TextStyle callout(BuildContext context) => _base(context).copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.32,
        height: 1.31,
      );

  static TextStyle subhead(BuildContext context) => _base(context).copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        height: 1.33,
      );

  static TextStyle footnote(BuildContext context) => _base(context).copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
        height: 1.38,
      );

  static TextStyle caption1(BuildContext context) => _base(context).copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
      );

  static TextStyle caption2(BuildContext context) => _base(context).copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.07,
        height: 1.18,
      );

  static TextStyle mono(BuildContext context, {double size = 17, FontWeight weight = FontWeight.w600}) =>
      _base(context).copyWith(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: -0.4,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

abstract final class LGShape {
  static BorderRadius radius(double r) => BorderRadius.circular(r);

  static RoundedSuperellipseBorder border(double r, {BorderSide side = BorderSide.none}) =>
      RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(r), side: side);

  static Path path(Rect rect, double r) =>
      RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(r)).getOuterPath(rect);
}

abstract final class LGGlass {
  static const double blurHeavy = 32;
  static const double blurStandard = 24;
  static const double blurLight = 16;
  static const double saturation = 1.18;

  static ImageFilter filter({double blur = blurStandard, double saturate = saturation}) {
    return ImageFilter.compose(
      outer: ImageFilter.blur(sigmaX: blur, sigmaY: blur, tileMode: TileMode.clamp),
      inner: ColorFilter.matrix(saturationMatrix(saturate)),
    );
  }

  static List<double> saturationMatrix(double s) {
    const lumR = 0.2126, lumG = 0.7152, lumB = 0.0722;
    final sr = (1 - s) * lumR, sg = (1 - s) * lumG, sb = (1 - s) * lumB;
    return <double>[
      sr + s, sg, sb, 0, 0,
      sr, sg + s, sb, 0, 0,
      sr, sg, sb + s, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  static Gradient sheen(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: dark
          ? const [Color(0x0DFFFFFF), Color(0x00FFFFFF)]
          : const [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
      stops: const [0.0, 0.6],
    );
  }
}
