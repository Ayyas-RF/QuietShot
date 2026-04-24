import 'package:flutter/material.dart';
import '../game/quiet_shot_game.dart';

class MainMenuOverlay extends StatelessWidget {
  final QuietShotGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A), // Very dark gray
        image: DecorationImage(
          image: AssetImage('assets/images/crate.png'), // Subtle background texture
          repeat: ImageRepeat.repeat,
          opacity: 0.05,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'QUIET SHOT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const Text(
              'TACTICAL ELIMINATION PROTOTYPE',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 80),
            _MenuButton(
              text: 'START OPERATION',
              onPressed: () {
                game.startMatch();
              },
              isPrimary: true,
            ),
            const SizedBox(height: 20),
            _MenuButton(
              text: 'EXIT',
              onPressed: () {
                // For web/desktop, simple exit or just log
              },
            ),
            const SizedBox(height: 60),
            const Text(
              'WASD to Move | QE to Aim | Space to Fire',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.blueAccent : Colors.transparent,
          side: const BorderSide(color: Colors.blueAccent, width: 2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          elevation: isPrimary ? 8 : 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }
}
