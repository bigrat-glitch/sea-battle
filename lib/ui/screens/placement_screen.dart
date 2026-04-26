import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/game_engine.dart';
import '../widgets/board_grid.dart';
import '../widgets/apple_button.dart';
import '../../core/constants.dart';
import 'menu_screen.dart';

class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = context.watch<GameEngine>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: Stack(
          children: [
            Opacity(opacity: 0.05, child: CustomPaint(size: Size.infinite, painter: GridPainter())),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Заголовок (фіксована висота)
                  const Text("TACTICAL DEPLOYMENT",
                      style: TextStyle(letterSpacing: 8, fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  _statusBlock(e),

                  // ПОЛЕ (Гнучка висота - забирає все, що залишилось)
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Знаходимо максимально можливий розмір квадрата
                          double boardSize = min(constraints.maxWidth, constraints.maxHeight) * 0.9;
                          return _labeledBoard(boardSize, e);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _orientationToggle(e),

                  const SizedBox(height: 24),
                  // Кнопка з'являється тільки коли треба, не займаючи зайвого місця
                  if (e.shipsToPlace.isEmpty)
                    AppleButton(text: "CONFIRM FLEET", onPressed: e.startGame)
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labeledBoard(double size, GameEngine e) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    double cellSize = size / 10;

    return FittedBox( // Автоматично масштабує поле з цифрами під розмір
      fit: BoxFit.contain,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              ...List.generate(10, (i) => SizedBox(
                height: cellSize,
                child: Center(child: Text("${i + 1}", style: const TextStyle(fontSize: 10, color: Colors.white24))),
              )),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Row(
                children: List.generate(10, (i) => SizedBox(
                  width: cellSize,
                  height: 20,
                  child: Center(child: Text(letters[i], style: const TextStyle(fontSize: 10, color: Colors.white24))),
                )),
              ),
              ClipRect(
                child: Stack(
                  children: [
                    SizedBox(
                      width: size,
                      height: size,
                      child: BoardGrid(board: e.playerBoard, onCellTap: e.placePlayerShip, isEnemy: false),
                    ),
                    AnimatedBuilder(
                      animation: _scannerController,
                      builder: (context, child) {
                        return Positioned(
                          top: _scannerController.value * size,
                          left: 0, right: 0,
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.transparent, AppColors.accent.withOpacity(0.3), Colors.transparent]),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBlock(GameEngine e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: e.shipsToPlace.isEmpty ? Colors.greenAccent.withOpacity(0.05) : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: e.shipsToPlace.isEmpty ? Colors.greenAccent.withOpacity(0.2) : Colors.white10),
      ),
      child: Text(
        e.shipsToPlace.isEmpty ? "ALL SYSTEMS GO" : "PLACING: ${e.currentShipSize}-DECK SHIP",
        style: TextStyle(fontFamily: 'monospace', color: e.shipsToPlace.isEmpty ? Colors.greenAccent : AppColors.accent, fontSize: 11),
      ),
    );
  }

  Widget _orientationToggle(GameEngine e) {
    return GestureDetector(
      onTap: e.toggleOrientation,
      child: Container(
        width: 200, height: 36,
        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: e.isVertical ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 100, margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const Row(
              children: [
                Expanded(child: Center(child: Text("HORIZONTAL", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))),
                Expanded(child: Center(child: Text("VERTICAL", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}