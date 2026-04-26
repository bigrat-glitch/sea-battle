import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wf/core/enums.dart';

class GameEngine extends ChangeNotifier {
  AppState appState = AppState.menu;
  List<CellState> playerBoard = List.filled(100, CellState.empty);
  List<CellState> aiBoard = List.filled(100, CellState.empty);

  bool playerTurn = true;
  String message = "READY";
  List<String> logs = [];
  double shakeIntensity = 0.0;

  int airStrikeAvailable = 1;
  int radarAvailable = 1;
  int aiAirStrikeAvailable = 1;

  bool isAirStrikeMode = false;
  bool isRadarMode = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  List<int> _aiTargetQueue = [];

  int currentShipSize = 4;
  bool isVertical = false;
  List<int> shipsToPlace = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];

  // --- СИСТЕМНІ МЕТОДИ ---

  void _playSound(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint("Sound error: $path | $e");
    }
  }

  void _triggerShake() {
    shakeIntensity = 12.0;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 150), () {
      shakeIntensity = 0.0;
      notifyListeners();
    });
  }

  // ТУТ ТЕПЕР notifyListeners() ПРАЦЮЄ ЧІТКО
  void _log(String msg) {
    final time = DateTime.now().toString().substring(11, 19);
    logs.add("$time | $msg");
    if (logs.length > 50) logs.removeAt(0);
    notifyListeners();
  }

  void goToMenu() {
    appState = AppState.menu;
    message = "";
    notifyListeners();
  }

  void goToPlacement() {
    appState = AppState.placement;
    playerBoard = List.filled(100, CellState.empty);
    shipsToPlace = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];
    currentShipSize = shipsToPlace[0];
    airStrikeAvailable = 1;
    aiAirStrikeAvailable = 1;
    radarAvailable = 1;
    logs.clear();
    _log("Ініціалізація систем розміщення...");
    notifyListeners();
  }

  void toggleOrientation() {
    isVertical = !isVertical;
    notifyListeners();
  }

  void placePlayerShip(int i) {
    if (shipsToPlace.isEmpty) return;
    int x = i % 10, y = i ~/ 10;
    if (_canPlace(playerBoard, x, y, currentShipSize, isVertical)) {
      for (int j = 0; j < currentShipSize; j++) {
        int idx = isVertical ? ((y + j) * 10 + x) : (y * 10 + x + j);
        playerBoard[idx] = CellState.ship;
      }
      // ДОДАНО ЛОГ
      _log("РОЗМІЩЕНО: ${currentShipSize}-палубник на позиції $i");

      shipsToPlace.removeAt(0);
      if (shipsToPlace.isNotEmpty) currentShipSize = shipsToPlace[0];
      _playSound('sounds/place.mp3');
      notifyListeners();
    }
  }

  bool _canPlace(List<CellState> b, int x, int y, int s, bool v) {
    if (v && y + s > 10 || !v && x + s > 10) return false;
    for (int i = 0; i < s; i++) {
      int cx = v ? x : x + i;
      int cy = v ? y + i : y;
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          int nx = cx + dx, ny = cy + dy;
          if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10 && b[ny * 10 + nx] == CellState.ship) return false;
        }
      }
    }
    return true;
  }

  void startGame() {
    _generateAiBoard();
    appState = AppState.game;
    playerTurn = true;
    message = "ТВІЙ ХІД";
    _log("БІЙ ПОЧАВСЯ. Командувач, вогонь!");
    notifyListeners();
  }

  void _generateAiBoard() {
    aiBoard = List.filled(100, CellState.empty);
    for (var s in [4, 3, 3, 2, 2, 2, 1, 1, 1, 1]) {
      bool placed = false;
      while (!placed) {
        int x = _random.nextInt(10), y = _random.nextInt(10);
        bool v = _random.nextBool();
        if (_canPlace(aiBoard, x, y, s, v)) {
          for (int i = 0; i < s; i++) aiBoard[v ? ((y + i) * 10 + x) : (y * 10 + x + i)] = CellState.ship;
          placed = true;
        }
      }
    }
  }

  void toggleAirStrike() {
    if (airStrikeAvailable > 0) {
      isAirStrikeMode = !isAirStrikeMode;
      isRadarMode = false;
      notifyListeners();
    }
  }

  void toggleRadar() {
    if (radarAvailable > 0) {
      isRadarMode = !isRadarMode;
      isAirStrikeMode = false;
      notifyListeners();
    }
  }

  void playerShoot(int i) {
    if (!playerTurn || appState != AppState.game) return;
    if (aiBoard[i] == CellState.hit || aiBoard[i] == CellState.miss) return;

    if (isAirStrikeMode) {
      _executeAirStrike(i);
    } else if (isRadarMode) {
      _executeRadar(i);
    } else {
      _processShot(aiBoard, i, isPlayer: true);
    }
  }

  void _executeAirStrike(int i) {
    airStrikeAvailable--;
    isAirStrikeMode = false;
    int x = i % 10, y = i ~/ 10;
    _log("АВІАУДАР: Сектор $x:$y під вогнем!");
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        int nx = x + dx, ny = y + dy;
        if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10) {
          _processShot(aiBoard, ny * 10 + nx, silent: true, isPlayer: true);
        }
      }
    }
    _triggerShake();
    _playSound('sounds/explosion.mp3');

    if (appState == AppState.game) {
      _log("Перезарядка авіаносія...");
      notifyListeners();
    }
  }

  void _executeRadar(int i) {
    radarAvailable--;
    isRadarMode = false;
    _log("РАДАР: Сканування сектору $i");
    int x = i % 10, y = i ~/ 10;
    bool found = false;
    for (int dy = 0; dy <= 1; dy++) {
      for (int dx = 0; dx <= 1; dx++) {
        int nx = x + dx, ny = y + dy;
        if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10 && aiBoard[ny * 10 + nx] == CellState.ship) found = true;
      }
    }
    message = found ? "ЦІЛЬ ВИЯВЛЕНО" : "СЕКТОР ЧИСТИЙ";
    _playSound('sounds/radar.mp3');

    Future.delayed(const Duration(seconds: 1), () {
      if (appState != AppState.game) return;
      playerTurn = false;
      message = "ХІД ВОРОГА";
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 1000), aiShoot);
    });
    notifyListeners();
  }

  // ДОДАНО ПАРАМЕТР isPlayer ДЛЯ ЛОГІВ
  void _processShot(List<CellState> board, int i, {bool silent = false, bool isPlayer = false}) {
    if (board[i] == CellState.hit || board[i] == CellState.miss) return;

    final actor = isPlayer ? "Гравець" : "Ворог";

    if (board[i] == CellState.ship) {
      board[i] = CellState.hit;
      _log("$actor: ВЛУЧАННЯ в сектор $i");
      if (!silent) {
        _playSound('sounds/hit.mp3');
        _triggerShake();
        HapticFeedback.mediumImpact();
      }
      _checkWin();
    } else {
      board[i] = CellState.miss;
      _log("$actor: ПРОМАХ в секторі $i");
      if (!silent) {
        _playSound('sounds/miss.mp3');
        if (isPlayer) {
          playerTurn = false;
          message = "ХІД ВОРОГА";
          Future.delayed(const Duration(milliseconds: 1000), aiShoot);
        } else {
          playerTurn = true;
          message = "ТВІЙ ХІД";
        }
      }
    }
    notifyListeners();
  }

  void aiShoot() {
    if (appState != AppState.game) return;

    if (aiAirStrikeAvailable > 0 && _random.nextDouble() < 0.15) {
      _executeAiAirStrike();
      return;
    }

    int t;
    if (_aiTargetQueue.isNotEmpty) {
      t = _aiTargetQueue.removeAt(0);
    } else {
      do { t = _random.nextInt(100); } while (playerBoard[t] == CellState.hit || playerBoard[t] == CellState.miss);
    }

    _processShot(playerBoard, t, isPlayer: false);

    // Якщо ШІ влучив, він стріляє ще раз (стандартне правило)
    if (playerBoard[t] == CellState.hit && appState == AppState.game) {
      _addNeighborsToQueue(t);
      Future.delayed(const Duration(milliseconds: 1200), aiShoot);
    }
  }

  void _executeAiAirStrike() {
    aiAirStrikeAvailable--;
    int target = _random.nextInt(100);
    int x = target % 10, y = target ~/ 10;
    _log("УВАГА! Ворожий авіаудар по $x:$y");
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        int nx = x + dx, ny = y + dy;
        if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10) {
          _processShot(playerBoard, ny * 10 + nx, silent: true, isPlayer: false);
        }
      }
    }
    _triggerShake();
    _playSound('sounds/explosion.mp3');

    if (appState == AppState.game) {
      playerTurn = true;
      message = "ТВІЙ ХІД";
      notifyListeners();
    }
  }

  void _addNeighborsToQueue(int i) {
    int x = i % 10, y = i ~/ 10;
    for (var d in [[0, 1], [0, -1], [1, 0], [-1, 0]]) {
      int nx = x + d[0], ny = y + d[1];
      if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10) {
        int idx = ny * 10 + nx;
        if (playerBoard[idx] == CellState.empty || playerBoard[idx] == CellState.ship) {
          if (!_aiTargetQueue.contains(idx)) _aiTargetQueue.add(idx);
        }
      }
    }
  }

  void _checkWin() {
    bool aiHasShips = aiBoard.any((cell) => cell == CellState.ship);
    bool playerHasShips = playerBoard.any((cell) => cell == CellState.ship);

    if (!aiHasShips) {
      // Тут можна додати AppState.victory для окремого екрану
      appState = AppState.menu;
      message = "ПЕРЕМОГА!";
      _playSound('sounds/final.mp3');
      _log("ГРА ЗАКІНЧЕНА: ПЕРЕМОГА ГРАВЦЯ");
    } else if (!playerHasShips) {
      appState = AppState.menu;
      message = "ПОРАЗКА";
      _playSound('sounds/lose.mp3');
      _log("ГРА ЗАКІНЧЕНА: ПЕРЕМОГА ВОРОГА");
    }
  }
}