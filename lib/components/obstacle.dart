import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../utils/constants.dart';
import '../game/quiet_shot_game.dart';

class Obstacle extends SpriteComponent with CollisionCallbacks, HasGameReference<QuietShotGame> {
  Obstacle({required Vector2 position, required Vector2 size})
      : super(
          position: position,
          size: size,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(GameConstants.crateSprite);
    add(RectangleHitbox());
  }
}
