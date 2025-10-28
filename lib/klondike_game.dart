import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'components/foundation.dart';
import 'components/pile.dart';
import 'components/stock.dart';
import 'components/waste.dart';

class KlondikeGame extends FlameGame {
  static const double cardGap = 175.0;
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);

  @override
  Future<void> onLoad() async {
    await Flame.images.load('klondike-sprites.png');

    // 山札と捨て札をテーブル上部に並べる。
    final stock = Stock()
      ..size = cardSize
      ..position = Vector2(cardGap, cardGap);
    final waste = Waste()
      ..size = cardSize
      ..position = Vector2(cardWidth + 2 * cardGap, cardGap);

    // 捨て札の右側に4つの場札置き場を用意する。
    final foundations = List.generate(
      4,
      (i) => Foundation()
        ..size = cardSize
        ..position = Vector2(
          (i + 3) * (cardWidth + cardGap) + cardGap,
          cardGap,
        ),
    );

    // 下段に7つの場札列（タブロー）を横並びで配置する。
    final piles = List.generate(
      7,
      (i) => Pile()
        ..size = cardSize
        ..position = Vector2(
          cardGap + i * (cardWidth + cardGap),
          cardHeight + 2 * cardGap,
        ),
    );

    // Flameのworldに登録して描画・更新対象にする。
    world.add(stock);
    world.add(waste);
    world.addAll(foundations);
    world.addAll(piles);

    // テーブル全体が入るようカメラの表示範囲と位置を調整する。
    camera.viewfinder.visibleGameSize = Vector2(
      // テーブルに必要な幅：カード7枚分＋隙間8箇所分
      cardWidth * 7 + cardGap * 8,
      // テーブルに必要な高さ：カード4枚分＋隙間3箇所分
      4 * cardHeight + 3 * cardGap,
    );
    // カメラの横位置をテーブルの中央に設定する。 [7*cardWidth + 8*cardGap] / 2)
    camera.viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0);
    // カメラの縦位置はトップに固定する。
    camera.viewfinder.anchor = Anchor.topCenter;
  }
}

Sprite klondikeSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('klondike-sprites.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
