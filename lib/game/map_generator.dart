import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../components/obstacle.dart';

class MapGenerator {
  static void generateLevel(FlameGame game) {
    final random = Random();
    final double width = game.size.x;
    final double height = game.size.y;

    // Clear existing obstacles if any
    game.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());

    // Generate random crates
    int crateCount = 12 + random.nextInt(8);
    for (int i = 0; i < crateCount; i++) {
      double x = 100 + random.nextDouble() * (width - 200);
      double y = 100 + random.nextDouble() * (height - 200);
      
      // Avoid spawning directly on the player start (100, 100) or bot start (width-100, height-100)
      if (Vector2(x, y).distanceTo(Vector2(100, 100)) < 100 || 
          Vector2(x, y).distanceTo(Vector2(width - 100, height - 100)) < 100) {
        continue;
      }

      game.add(Obstacle(
        position: Vector2(x, y),
        size: Vector2(40 + random.nextDouble() * 40, 40 + random.nextDouble() * 40),
      ));
    }
    
    // Add some "corner" cover
    game.add(Obstacle(position: Vector2(width / 2 - 25, 50), size: Vector2(50, 100)));
    game.add(Obstacle(position: Vector2(width / 2 - 25, height - 150), size: Vector2(50, 100)));
  }
}
