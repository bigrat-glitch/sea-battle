import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/game_engine.dart';
import '../widgets/board_grid.dart';
import '../../core/constants.dart';
import '../../core/enums.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final e = context.watch<GameEngine>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(e),
                const Spacer(),
                _buildAbilityBar(e),
                const Spacer(),
                Expanded(
                  flex: 20,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 850;
                      double boardSize = isWide
                          ? min(constraints.maxWidth / 2.3, constraints.maxHeight * 0.9)
                          : min(constraints.maxWidth * 0.95, constraints.maxHeight / 2.3);

                      return isWide
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _field("COMMANDER FLEET", e.playerBoard, false, boardSize, e),
                          _field("HOSTILE TARGET", e.aiBoard, true, boardSize, e, onCellTap: e.playerShoot),
                        ],
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _field("HOSTILE TARGET", e.aiBoard, true, boardSize, e, onCellTap: e.playerShoot),
                          _field("COMMANDER FLEET", e.playerBoard, false, boardSize, e),
                        ],
                      );
                    },
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameEngine e) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _tile("STATUS", e.playerTurn ? "ONLINE" : "AI THINKING", e.playerTurn ? Colors.greenAccent : Colors.orangeAccent),
          SizedBox(
            width: 250,
            child: Center(
              child: Text(e.message.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.blueAccent)),
            ),
          ),
          _tile("RADAR", e.radarAvailable > 0 ? "READY" : "OFFLINE", e.radarAvailable > 0 ? Colors.cyanAccent : Colors.white24),
        ],
      ),
    );
  }

  Widget _buildAbilityBar(GameEngine e) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn(icon: Icons.gps_fixed, label: "AIR STRIKE [${e.airStrikeAvailable}]", active: e.isAirStrikeMode, color: Colors.orangeAccent, onTap: e.toggleAirStrike),
        const SizedBox(width: 20),
        _btn(icon: Icons.radar, label: "SCANNER [${e.radarAvailable}]", active: e.isRadarMode, color: Colors.cyanAccent, onTap: e.toggleRadar),
      ],
    );
  }

  Widget _btn({required IconData icon, required String label, required bool active, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: active ? color : Colors.white10),
        ),
        child: Row(children: [Icon(icon, size: 14, color: active ? color : Colors.white54), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? color : Colors.white54))]),
      ),
    );
  }

  Widget _tile(String l, String v, Color c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 7, color: Colors.white24)), Text(v, style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.bold))]);

  Widget _field(String label, List<CellState> board, bool isEnemy, double size, GameEngine e, {Function(int)? onCellTap}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, letterSpacing: 4, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          width: size, height: size,
          child: BoardGrid(
            board: board,
            isEnemy: isEnemy,
            onCellTap: onCellTap,
            airStrikeMode: isEnemy && e.isAirStrikeMode,
            radarMode: isEnemy && e.isRadarMode,
          ),
        ),
      ],
    );
  }
}