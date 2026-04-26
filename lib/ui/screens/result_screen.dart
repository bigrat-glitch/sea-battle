class ResultOverlay extends StatelessWidget {
  final bool isWin;
  final VoidCallback onRestart;

  const ResultOverlay({super.key, required this.isWin, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black90,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isWin ? Icons.verified : Icons.dangerous, size: 100, color: isWin ? Colors.greenAccent : Colors.redAccent),
            const SizedBox(height: 20),
            Text(isWin ? "MISSION ACCOMPLISHED" : "FLEET DESTROYED",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w100, letterSpacing: 10)),
            const SizedBox(height: 10),
            Text(isWin ? "THE SECTOR IS SECURED" : "CRITICAL SYSTEMS FAILURE",
                style: const TextStyle(color: Colors.white24, letterSpacing: 2)),
            const SizedBox(height: 60),
            AppleButton(text: "RETURN TO BASE", onPressed: onRestart),
          ],
        ),
      ),
    );
  }
}