import 'dart:ui';

import 'package:flame/components.dart';

import '../klondike_game.dart';
import '../pile.dart';
import '../suit.dart';
import 'card.dart';

// 画面の右上に配置される、4つの場札置き場（Foundation Pile）の1つを表します。
class FoundationPile extends PositionComponent implements Pile {
  FoundationPile(int intSuit, {super.position})
    : suit = Suit.fromInt(intSuit),
      super(size: KlondikeGame.cardSize);

  final Suit suit;
  final List<Card> _cards = [];

  //#region Pile API

  @override
  bool canMoveCard(Card card) {
    return _cards.isNotEmpty && card == _cards.last;
  }

  @override
  bool canAcceptCard(Card card) {
    final topCardRank = _cards.isEmpty ? 0 : _cards.last.rank.value;
    return card.suit == suit &&
        card.rank.value == topCardRank + 1 &&
        card.attachedCards.isEmpty;
  }

  @override
  void removeCard(Card card) {
    assert(canMoveCard(card));
    _cards.removeLast();
  }

  @override
  void returnCard(Card card) {
    card.position = position;
    card.priority = _cards.indexOf(card);
  }

  // acquireとgetの英語のニュアンスの違いは、acquireは「獲得する」、getは「取る」という違いがあります。
  // acquireCardはカードが新たにこの場札置き場に加わることを意味し、
  // getCardは既にこの場札置き場にあるカードを取得することを意味します。
  @override
  void acquireCard(Card card) {
    assert(card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    card.pile = this;
    _cards.add(card);
  }

  //#endregion

  //#region Rendering

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0x50ffffff);
  late final _suitPaint = Paint()
    ..color = suit.isRed ? const Color(0x3a000000) : const Color(0x64000000)
    // luminosity: 元の色の明るさを保ちながら、指定した色で描画する
    ..blendMode = BlendMode.luminosity;

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    suit.sprite.render(
      canvas,
      position: size / 2,
      anchor: Anchor.center,
      size: Vector2.all(KlondikeGame.cardWidth * 0.6),
      overridePaint: _suitPaint,
    );
  }

  //#endregion
}
