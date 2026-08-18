import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../services/maps_config.dart';
import '../theme/app_colors.dart';
import '../ui/glass.dart';

class TravellyLogo extends StatelessWidget {
  final double size;

  const TravellyLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    // PLACEHOLDER_ASSET: replace with Image.asset('assets/images/travelly_logo.png')
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
      child: Icon(CupertinoIcons.bolt_fill, color: const Color(0xFFFFFFFF), size: size * 0.62),
    );
  }
}

class SoftCityBackground extends StatelessWidget {
  const SoftCityBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF10231B), Color(0xFF000000)]
              : const [Color(0xFFE8F4EC), Color(0xFFF2F2F7)],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class PlaceholderPet extends StatelessWidget {
  final double size;

  const PlaceholderPet({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: dark ? const Color(0xFF2C2C2E) : const Color(0xFFFFFFFF),
        shape: LGShape.border(
          LGRadius.md,
          side: BorderSide(
            color: LGColor.resolve(LGColor.separator, context).withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
      ),
    );
  }
}

class PlaceholderMap extends StatelessWidget {
  const PlaceholderMap({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(MapsConfig.defaultLat, MapsConfig.defaultLng),
          initialZoom: 13,
          interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate: MapsConfig.tileUrl,
            userAgentPackageName: MapsConfig.userAgent,
            maxNativeZoom: 19,
          ),
        ],
      ),
    );
  }
}

class MiniGraph extends StatelessWidget {
  const MiniGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: MiniGraphPainter(), child: const SizedBox(width: 95, height: 58));
  }
}

class MiniGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = AppColors.green.withValues(alpha: 0.23);
    final line = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final area = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.78)
      ..lineTo(size.width * 0.25, size.height * 0.65)
      ..lineTo(size.width * 0.45, size.height * 0.50)
      ..lineTo(size.width * 0.68, size.height * 0.34)
      ..lineTo(size.width, size.height * 0.10)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(area, fill);

    final graph = Path()
      ..moveTo(0, size.height * 0.78)
      ..lineTo(size.width * 0.25, size.height * 0.65)
      ..lineTo(size.width * 0.45, size.height * 0.50)
      ..lineTo(size.width * 0.68, size.height * 0.34)
      ..lineTo(size.width, size.height * 0.10);

    canvas.drawPath(graph, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
