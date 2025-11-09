import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../klondike_game.dart';
import '../pile.dart';
import '../rank.dart';
import '../suit.dart';
import 'tableau_pile.dart';

// カード1枚を表します。
class Card extends PositionComponent with DragCallbacks {
  Card(int intRank, int intSuit)
    : rank = Rank.fromInt(intRank),
      suit = Suit.fromInt(intSuit),
      super(size: KlondikeGame.cardSize);

  final Rank rank;
  final Suit suit;
  Pile? pile;
  bool _faceUp = false;
  bool _isDragging = false;
  final List<Card> attachedCards = [];

  bool get isFaceUp => _faceUp;
  bool get isFaceDown => !_faceUp;
  void flip() => _faceUp = !_faceUp;

  @override
  String toString() => rank.label + suit.label; // e.g. "Q♠" or "10♦"

  // PositionComponentのrenderメソッドは、このコンポーネントのローカル座標で描画される
  // つまり、(0,0)が左上、(width,height)が右下となる
  @override
  void render(Canvas canvas) {
    if (_faceUp) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  static final Paint backBackgroundPaint = Paint()
    ..color = const Color(0xff380c02);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color(0xffdbaf58)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color(0x5CEF971B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  // カードの外枠と内枠のRRectオブジェクトを作成
  // RRectは四隅が丸い長方形を表すクラス
  static final RRect cardRRect = RRect.fromRectAndRadius(
    // カードのサイズを指定
    KlondikeGame.cardSize.toRect(),
    // 四隅の丸みの半径を指定
    const Radius.circular(KlondikeGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
  static final Sprite flameSprite = klondikeSprite(1367, 6, 357, 501);

  // カードの裏面を描画
  void _renderBack(Canvas canvas) {
    // 背景色
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    // 枠線（外側）
    canvas.drawRRect(cardRRect, backBorderPaint1);
    // 枠線（内側）
    canvas.drawRRect(backRRectInner, backBorderPaint2);
    // 中央の炎のロゴ画像
    // Anchor.centerを指定してカードの中央に描画する
    flameSprite.render(canvas, position: size / 2, anchor: Anchor.center);
  }

  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color(0xff000000);
  static final Paint redBorderPaint = Paint()
    ..color = const Color(0xffece8a3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint blackBorderPaint = Paint()
    ..color = const Color(0xff7ab2e8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  // 枠線（内側）
  static final blueFilter = Paint()
    // ColorFilterを使って青色で色付けする
    ..colorFilter = const ColorFilter.mode(
      Color(0x880d8bff),
      // ブレンドモードを指定
      // srcATopは、元の画像のアルファ値を保持しつつ、指定した色で色付けするモード
      BlendMode.srcATop,
    );
  // 各絵札のスプライトを用意
  // staticとしておくことで、Cardクラス全体で共有できるようにする
  // static宣言は、クラス内で一度だけ初期化されるため、メモリの節約になる
  static final Sprite redJack = klondikeSprite(81, 565, 562, 488);
  static final Sprite redQueen = klondikeSprite(717, 541, 486, 515);
  static final Sprite redKing = klondikeSprite(1305, 532, 407, 549);
  static final Sprite blackJack = klondikeSprite(81, 565, 562, 488)
    ..paint = blueFilter;
  static final Sprite blackQueen = klondikeSprite(717, 541, 486, 515)
    ..paint = blueFilter;
  static final Sprite blackKing = klondikeSprite(1305, 532, 407, 549)
    ..paint = blueFilter;

  void _renderFront(Canvas canvas) {
    // カードの表面背景と枠線を描画
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(cardRRect, suit.isRed ? redBorderPaint : blackBorderPaint);

    // ランクとスートの絵柄を描画
    final rankSprite = suit.isBlack ? rank.blackSprite : rank.redSprite;
    final suitSprite = suit.sprite;
    // スプライトを描画
    // 0.1, 0.08は、カードの左上からの相対位置（10%、8%の位置）
    // この位置を基準にして、反転した位置にも同じものを描画する
    _drawSprite(canvas, rankSprite, 0.1, 0.08);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5);
    _drawSprite(canvas, rankSprite, 0.1, 0.08, rotate: true);
    _drawSprite(canvas, suitSprite, 0.1, 0.18, scale: 0.5, rotate: true);
    switch (rank.value) {
      case 1:
        _drawSprite(canvas, suitSprite, 0.5, 0.5, scale: 2.5);
      case 2:
        _drawSprite(canvas, suitSprite, 0.5, 0.25);
        _drawSprite(canvas, suitSprite, 0.5, 0.25, rotate: true);
      case 3:
        _drawSprite(canvas, suitSprite, 0.5, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
        _drawSprite(canvas, suitSprite, 0.5, 0.2, rotate: true);
      case 4:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
      case 5:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.5);
      case 6:
        _drawSprite(canvas, suitSprite, 0.3, 0.25);
        _drawSprite(canvas, suitSprite, 0.7, 0.25);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.25, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.25, rotate: true);
      case 7:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
      case 8:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.35);
        _drawSprite(canvas, suitSprite, 0.3, 0.5);
        _drawSprite(canvas, suitSprite, 0.7, 0.5);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.35, rotate: true);
      case 9:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
      case 10:
        _drawSprite(canvas, suitSprite, 0.3, 0.2);
        _drawSprite(canvas, suitSprite, 0.7, 0.2);
        _drawSprite(canvas, suitSprite, 0.5, 0.3);
        _drawSprite(canvas, suitSprite, 0.3, 0.4);
        _drawSprite(canvas, suitSprite, 0.7, 0.4);
        _drawSprite(canvas, suitSprite, 0.3, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.2, rotate: true);
        _drawSprite(canvas, suitSprite, 0.5, 0.3, rotate: true);
        _drawSprite(canvas, suitSprite, 0.3, 0.4, rotate: true);
        _drawSprite(canvas, suitSprite, 0.7, 0.4, rotate: true);
      case 11:
        _drawSprite(canvas, suit.isRed ? redJack : blackJack, 0.5, 0.5);
      case 12:
        _drawSprite(canvas, suit.isRed ? redQueen : blackQueen, 0.5, 0.5);
      case 13:
        _drawSprite(canvas, suit.isRed ? redKing : blackKing, 0.5, 0.5);
    }
  }

  // スプライトを描画するヘルパーメソッド
  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    // 180度回転する場合の処理
    if (rotate) {
      // PositionComponentのrenderメソッド内でcanvasは、初期値がローカル座標の(0,0)からスタートするので、
      // カードの回転軸を中心に移動する必要がある

      // 回転軸の座標に移動する前に現在の座標系を保存しておく
      canvas.save();

      // 回転の中心をカードの中心に移動する
      // canvas.translate(Anchor.center.toVector2().x, Anchor.center.toVector2().y); とすると、
      // Anchor.centerは(0.5,0.5)なので、カードサイズを考慮できておらず、正しい位置に移動できない
      // そのため、Anchor.center.toVector2()で得られた(0.5,0.5)にカードのサイズを掛け算して
      // 実際のピクセル座標に変換する必要がある
      // 例） Vector2 centerOffset = Anchor.center.toVector2();
      //    canvas.translate(centerOffset.x * size.x, centerOffset.y * size.y);
      // これは分かりにくいため、以下の方が直感的で素直に読める
      canvas.translate(size.x / 2, size.y / 2);
      // 180度回転
      canvas.rotate(pi);
      // 元の位置に戻す
      canvas.translate(-size.x / 2, -size.y / 2);
      // そもそもcanvasとは、描画領域全体を指すオブジェクトであり、
      // その上で描画位置を変換することで、描画内容を操作している
      // そのため、回転やスケーリングを行う場合は、必ずsave()とrestore()で状態を管理する必要がある

      // canvas.rotate()やcanvas.scale()は、canvas全体に影響を与えるため、
      // それらの操作を行う前にcanvasの状態を保存し、
      // 描画が終わった後に元の状態に戻すことで、他の描画に影響を与えないようにする

      // canvas.translate()は、描画位置を移動させるためのメソッドであり、
      // これもcanvas全体に影響を与えるため、同様に
      // save()とrestore()で状態を管理する必要がある
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }

  //#region Dragging

  @override
  void onDragStart(DragStartEvent event) {
    // mixin で定義された onDragStart を呼び出す
    // これにより、PositionComponent のドラッグ処理が正しく動作する(_isDragging = true になる)
    // 終了時には、onDragEnd を呼び出す必要がある. これにより、ドラッグ操作が完了したときに適切なクリーンアップが行われる (_isDragging = false になる)
    // onDragUpdate()メソッド内のisDragged ゲッターで、ドラッグ中かどうかを判定できるようになる
    super.onDragStart(event);
    if (pile?.canMoveCard(this) ?? false) {
      _isDragging = true;
      priority = 100;
      if (pile is TableauPile) {
        attachedCards.clear();
        final extraCards = (pile! as TableauPile).cardsOnTop(this);
        for (final card in extraCards) {
          card.priority = attachedCards.length + 101;
          attachedCards.add(card);
        }
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging) {
      return;
    }
    final delta = event.localDelta;
    position.add(delta);
    attachedCards.forEach((card) => card.position.add(delta));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!_isDragging) {
      return;
    }
    _isDragging = false;
    final dropPiles = parent!
        .componentsAtPoint(position + size / 2)
        .whereType<Pile>()
        .toList();
    if (dropPiles.isNotEmpty) {
      if (dropPiles.first.canAcceptCard(this)) {
        pile!.removeCard(this);
        dropPiles.first.acquireCard(this);
        if (attachedCards.isNotEmpty) {
          attachedCards.forEach((card) => dropPiles.first.acquireCard(card));
          attachedCards.clear();
        }
        return;
      }
    }
    pile!.returnCard(this);
    if (attachedCards.isNotEmpty) {
      attachedCards.forEach((card) => pile!.returnCard(card));
      attachedCards.clear();
    }
  }

  //#endregion
}
