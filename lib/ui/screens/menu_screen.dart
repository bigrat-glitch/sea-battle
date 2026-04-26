import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/game_engine.dart';
import '../widgets/apple_button.dart';
import '../../core/constants.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final e = context.read<GameEngine>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
        ),
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: CustomPaint(
              size: Size.infinite,
              painter: GridPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (e.message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(e.message, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                const Icon(Icons.blur_on, size: 80, color: AppColors.accent),
                const SizedBox(height: 20),
                const Text(
                  "SEA BATTLE",
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 12,
                    color: AppColors.textMain,
                  ),
                ),
                const Text(
                  "TACTICAL NAVAL SIMULATION",
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 4,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 80),
                AppleButton(
                  text: "INITIATE MISSION",
                  onPressed: e.goToPlacement,
                  isPrimary: true,
                ),
                const SizedBox(height: 20),
                Text(
                  "V 1.0.4 | SYSTEM READY",
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.greenAccent.withOpacity(0.5),
                      fontFamily: 'monospace'
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}