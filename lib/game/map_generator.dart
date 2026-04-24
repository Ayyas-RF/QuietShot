import 'dart:math';
import 'package:flame/game.dart';
import '../components/obstacle.dart';

class MapGenerator {
  static void generateLevel(FlameGame game) {
    final random = Random();
    final double width = game.size.x;
    final double height = game.size.y;

    // Clear existing obstacles if any
    game.children.whereType<Obstacle>().forEach((o) => o.removeFromParent());

    const double gridSize = 80.0; // Larger grid for logical spacing
    final int cols = (width / gridSize).floor();
    final int rows = (height / gridSize).floor();

    // Use a grid to ensure spacing
    final List<List<bool>> occupied = List.generate(
      rows, (i) => List.generate(cols, (j) => false)
    );

    // Reserve Spawn Zones (indices)
    // Player: Top-Left (0,0 to 2,2)
    // Bot: Bottom-Right (cols-3,rows-3 to cols-1,rows-1)
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        if (r < rows && c < cols) occupied[r][c] = true;
        if (rows - 1 - r >= 0 && cols - 1 - c >= 0) {
          occupied[rows - 1 - r][cols - 1 - c] = true;
        }
      }
    }

    // Number of clusters to generate
    int clusterCount = 5 + random.nextInt(3);

    for (int i = 0; i < clusterCount; i++) {
      // Pick a random un-occupied start point for a cluster
      int startR = 1 + random.nextInt(rows - 2);
      int startC = 1 + random.nextInt(cols - 2);

      if (occupied[startR][startC]) continue;

      // Choose cluster shape (L, I, or Box)
      int type = random.nextInt(3);
      _spawnCluster(game, startR, startC, type, occupied, gridSize);
    }
  }

  static void _spawnCluster(FlameGame game, int r, int c, int type, List<List<bool>> occupied, double gridSize) {
    final random = Random();
    
    // List of relative offsets for different cluster types
    List<List<int>> offsets;
    if (type == 0) { // L-Shape
      offsets = [[0, 0], [1, 0], [1, 1]];
    } else if (type == 1) { // Wall-Shape
      bool horizontal = random.nextBool();
      offsets = horizontal ? [[0, 0], [0, 1], [0, 2]] : [[0, 0], [1, 0], [2, 0]];
    } else { // Single Crate or Small Box
      offsets = [[0, 0]];
    }

    for (var offset in offsets) {
      int targetR = r + offset[0];
      int targetC = c + offset[1];

      if (targetR >= 0 && targetR < occupied.length && 
          targetC >= 0 && targetC < occupied[0].length &&
          !occupied[targetR][targetC]) {
        
        occupied[targetR][targetC] = true;
        
        // Add actual obstacle with slight randomization in size within grid cell
        game.add(Obstacle(
          position: Vector2(targetC * gridSize + 5, targetR * gridSize + 5),
          size: Vector2(gridSize - 10, gridSize - 10),
        ));
      }
    }
  }
}
