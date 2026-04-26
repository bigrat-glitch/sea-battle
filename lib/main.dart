import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:wf/core/enums.dart';
import 'package:wf/core/constants.dart';
import 'package:wf/logic/game_engine.dart';
import 'package:wf/ui/screens/menu_screen.dart';
import 'package:wf/ui/screens/placement_screen.dart';
import 'package:wf/ui/screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameEngine(),
      child: const SeaBattleApp(),
    ),
  );
}

class SeaBattleApp extends StatelessWidget {
  const SeaBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sea Battle: Tactical',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const MainRouter(),
    );
  }
}

class MainRouter extends StatelessWidget {
  const MainRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final e = context.watch<GameEngine>();
    final rand = Random();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 100),
      tween: Tween(begin: 0.0, end: e.shakeIntensity),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * (rand.nextBool() ? 1 : -1), value * (rand.nextBool() ? 1 : -1)),
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _buildCurrentScreen(e.appState),
        ),
        floatingActionButton: e.appState == AppState.game
            ? FloatingActionButton.small(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.accent.withOpacity(0.3)),
          ),
          onPressed: () => _showLogs(context, e),
          child: const Icon(Icons.terminal, color: Colors.greenAccent, size: 18),
        )
            : null,
      ),
    );
  }

  Widget _buildCurrentScreen(AppState state) {
    switch (state) {
      case AppState.menu: return const MenuScreen(key: ValueKey('menu'));
      case AppState.placement: return const PlacementScreen(key: ValueKey('placement'));
      case AppState.game: return const GameScreen(key: ValueKey('game'));
    }
  }

  void _showLogs(BuildContext context, GameEngine e) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.accent.withOpacity(0.5))),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TACTICAL DATA LOGS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 10, color: AppColors.accent)),
                  Row(
                    children: [
                      // КНОПКА ЕКСПОРТУ
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: e.logs.join('\n')));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("LOGS COPIED TO CLIPBOARD"), duration: Duration(seconds: 1)));
                        },
                        icon: const Icon(Icons.copy, size: 14, color: Colors.greenAccent),
                        label: const Text("EXPORT", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                      ),
                      IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              Expanded(
                child: ListView.builder(
                  itemCount: e.logs.length,
                  itemBuilder: (c, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "> ${e.logs[e.logs.length - 1 - i]}",
                      style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}