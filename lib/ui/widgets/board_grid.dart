import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wf/core/enums.dart';
import '../../core/constants.dart';

class BoardGrid extends StatefulWidget {
  final List<CellState> board;
  final Function(int)? onCellTap;
  final bool isEnemy;
  final bool airStrikeMode;
  final bool radarMode;

  const BoardGrid({
    super.key,
    required this.board,
    this.onCellTap,
    this.isEnemy = false,
    this.airStrikeMode = false,
    this.radarMode = false,
  });

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  int? hoveredIndex;

  bool _isInZone(int index) {
    if (hoveredIndex == null) return false;
    int hx = hoveredIndex! % 10, hy = hoveredIndex! ~/ 10;
    int cx = index % 10, cy = index ~/ 10;

    if (widget.airStrikeMode) {
      return (cx - hx).abs() <= 1 && (cy - hy).abs() <= 1;
    } else if (widget.radarMode) {
      return (cx >= hx && cx <= hx + 1) && (cy >= hy && cy <= hy + 1);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => setState(() => hoveredIndex = null),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
          itemCount: 100,
          itemBuilder: (context, i) {
            bool highlight = _isInZone(i);
            return MouseRegion(
              onEnter: (_) => setState(() => hoveredIndex = i),
              child: GestureDetector(
                onTap: widget.onCellTap != null ? () => widget.onCellTap!(i) : null,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
                    color: highlight
                        ? (widget.airStrikeMode ? Colors.orange.withOpacity(0.3) : Colors.cyan.withOpacity(0.3))
                        : _getBgColor(widget.board[i]),
                  ),
                  child: Center(child: _getIndicator(widget.board[i])),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getBgColor(CellState s) {
    if (s == CellState.hit) return Colors.red.withOpacity(0.15);
    if (!widget.isEnemy && s == CellState.ship) return AppColors.accent.withOpacity(0.1);
    return Colors.transparent;
  }

  Widget? _getIndicator(CellState s) {
    if (s == CellState.hit) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(6, (index) => _ParticleItem(index: index)),
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)],
            ),
          ),
          const FittedBox(child: Icon(Icons.close, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      );
    }
    if (s == CellState.miss) {
      return Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle));
    }
    if (!widget.isEnemy && s == CellState.ship) {
      return Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: AppColors.accent, borderRadius: BorderRadius.circular(2),
          boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(1), blurRadius: 8, spreadRadius: 1)],
        ),
      );
    }
    return null;
  }
}

class _ParticleItem extends StatelessWidget {
  final int index;
  const _ParticleItem({required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, val, child) {
        double angle = (index * 60) * (pi / 180);
        double dist = val * 18;
        return Transform.translate(
          offset: Offset(cos(angle) * dist, sin(angle) * dist),
          child: Opacity(
            opacity: 1 - val,
            child: Container(width: 2, height: 2, color: Colors.orangeAccent),
          ),
        );
      },
    );
  }
}