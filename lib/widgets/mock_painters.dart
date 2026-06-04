import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
      child: Icon(Icons.bolt, color: Colors.white, size: size * 0.62),
    );
  }
}

class SoftCityBackground extends StatelessWidget {
  const SoftCityBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // PLACEHOLDER_ASSET: replace with exported Figma welcome background.
    return CustomPaint(painter: CityPainter(), child: const SizedBox.expand());
  }
}

class PlaceholderPet extends StatelessWidget {
  final double size;

  const PlaceholderPet({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    // PLACEHOLDER_ASSET: replace with Image.asset('assets/images/puppy.png')
    return SizedBox(width: size, height: size, child: CustomPaint(painter: PetPainter()));
  }
}

class PlaceholderMap extends StatelessWidget {
  const PlaceholderMap({super.key});

  @override
  Widget build(BuildContext context) {
    // PLACEHOLDER_ASSET: replace with real map integration or exported map image.
    return CustomPaint(painter: MapPainter(), child: const SizedBox.expand());
  }
}

class CityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF7FFF4), Color(0xFFEAF6E7)],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bg);

    final cloud = Paint()..color = Colors.white.withOpacity(0.75);
    for (final x in [20.0, 85.0, 240.0, 330.0]) {
      canvas.drawCircle(Offset(x, size.height * 0.58), 52, cloud);
    }

    final buildingPaints = [
      Paint()..color = const Color(0xFF79C8A8),
      Paint()..color = const Color(0xFFFFDFA8),
      Paint()..color = const Color(0xFF65B89B),
    ];

    for (double x = 15; x < size.width; x += 34) {
      final h = 52 + (x % 90);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height - h - 95, 23, h),
          const Radius.circular(3),
        ),
        buildingPaints[(x ~/ 34) % buildingPaints.length],
      );
    }

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height - 88, size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE8F2DE));

    canvas.drawCircle(Offset(26, size.height - 68), 68, Paint()..color = AppColors.greenDark.withOpacity(0.65));
    canvas.drawCircle(Offset(size.width - 15, size.height - 72), 74, Paint()..color = AppColors.greenDark.withOpacity(0.62));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final brown = Paint()..color = const Color(0xFFD58C45);
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;

    final leftEar = Path()
      ..moveTo(size.width * 0.30, size.height * 0.26)
      ..lineTo(size.width * 0.12, size.height * 0.08)
      ..lineTo(size.width * 0.18, size.height * 0.43)
      ..close();

    final rightEar = Path()
      ..moveTo(size.width * 0.70, size.height * 0.26)
      ..lineTo(size.width * 0.88, size.height * 0.08)
      ..lineTo(size.width * 0.82, size.height * 0.43)
      ..close();

    canvas.drawPath(leftEar, brown);
    canvas.drawPath(rightEar, brown);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.58), size.width * 0.28, white);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.39), size.width * 0.24, white);
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.36), 3, black);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.36), 3, black);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.47), 4, black);
    canvas.drawCircle(Offset(size.width * 0.36, size.height * 0.62), 8, brown);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFECECEC));

    final park = Paint()..color = const Color(0xFFCFE8CF);
    canvas.drawRect(Rect.fromLTWH(20, 90, 135, 100), park);
    canvas.drawRect(Rect.fromLTWH(size.width - 160, 250, 140, 120), park);

    final river = Paint()
      ..color = const Color(0xFF78CDE9)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final orange = Paint()
      ..color = const Color(0xFFFFC46B)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(size.width * 0.65, -20), Offset(size.width * 0.45, size.height + 20), river);

    canvas.drawLine(Offset(0, size.height * 0.22), Offset(size.width, size.height * 0.10), road);
    canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.45), road);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.33, size.height), road);

    canvas.drawLine(Offset(0, size.height * 0.22), Offset(size.width, size.height * 0.10), orange);
    canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.45), orange);

    final route = Paint()
      ..color = AppColors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(45, size.height - 135), Offset(size.width * 0.48, size.height * 0.52), route);
    canvas.drawLine(Offset(size.width * 0.48, size.height * 0.52), Offset(size.width - 55, 120), route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final fill = Paint()..color = AppColors.green.withOpacity(0.23);
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
