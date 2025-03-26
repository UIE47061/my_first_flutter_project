import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

extension OffsetExtension on Offset {
  Offset normalize() {
    final double distance = this.distance;
    if (distance == 0.0) {
      return Offset.zero; // 避免除以零
    }
    return Offset(dx / distance, dy / distance);
  }
}

class Bubble {
  Offset position;
  Offset velocity;
  double radius;
  Color color;
  double groundFriction; // 底部摩擦力

  Bubble({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    this.groundFriction = 0.8, // 預設值
  });
}

class BubblePage extends StatefulWidget {
  const BubblePage({Key? key}) : super(key: key);

  @override
  State<BubblePage> createState() => _BubblePageState();
}

class _BubblePageState extends State<BubblePage> with SingleTickerProviderStateMixin {
  List<Bubble> bubbles = [];
  late Ticker _ticker;
  final int numberOfBubbles = 20; // 可以調整球的數量
  final double bubbleRadius = 17; // 可以調整珍珠的半徑
  final double bounceFactor = 0.1; // 減少反彈的強度
  final double gravity = 0.4;
  final double groundFriction = 0.9;
  final double dampingFactor = 0.92; // 增加阻尼
  final double restingVelocityThreshold = 0.1;
  final int collisionResolutionIterations = 3;
  late double appearX;

  // **Cup Boundary Variables**
  late double cupLeft;
  late double cupRight;
  late double cupTop;
  late double cupBottom;

  // **Arc Parameters**
  late double arcCenterX; // 中心 X 座標
  late double arcCenterY; // 中心 Y 座標
  late double arcRadius;  // 弧形的半徑

  int bubblesCreated = 0; // 追蹤已創建的球體數量
  final double creationInterval = 20; // 創建間隔 (秒)
  double timeSinceLastBubble = 0; // 上次創建球體的時間
  late double cupWidth;
  late double cupHeight;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_update);
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appearX = MediaQuery.of(context).size.width / 2;

    // 根據螢幕尺寸計算杯子的邊界和圓弧的參數
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    cupLeft = screenWidth * 0.3;
    cupRight = screenWidth * 0.7;
    cupTop = screenHeight * 0.2;
    cupBottom = screenHeight * 0.7;

    // 確保圓形的 X 軸位置與長方形對齊
    arcCenterX = (cupLeft + cupRight) / 2; // 中心 X 座標
    arcCenterY = screenHeight * 0.6; // 中心 Y 座標
    arcRadius = screenWidth * 0.16;  // 弧形的半徑

    cupWidth = cupRight - cupLeft;
    cupHeight = cupBottom - cupTop;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool isInsideCup(Bubble bubble) {
    // Check if the bubble is completely outside the rectangular area
    if (_isOutsideRectangularArea(bubble)) {
      return false;
    }

    // Check if the bubble is below the arc
    if (_isBelowArc(bubble)) {
      return false;
    }

    // Otherwise, the bubble is inside the cup
    return true;
  }

  bool _isOutsideRectangularArea(Bubble bubble) {
    return bubble.position.dx + bubble.radius < cupLeft ||
        bubble.position.dx - bubble.radius > cupRight;
  }

  bool _isBelowArc(Bubble bubble) {
    double distanceToCenterX = bubble.position.dx - arcCenterX;
    double arcHeightAtBubbleX = arcCenterY + sqrt(max(0, arcRadius * arcRadius - pow(distanceToCenterX, 2)));

    return bubble.position.dy - bubble.radius > arcHeightAtBubbleX;
  }

  void _createBubble() {
    double radius = bubbleRadius;

    // Constrain the bubble's starting position to the cup area
    appearX = cupLeft + (Random().nextDouble() * cupWidth);
    double spawnHeight = cupHeight / 2; // 从杯子高度的一半开始生成

    double appearY = cupTop + Random().nextDouble() * spawnHeight;

    bubbles.add(
      Bubble(
        position: Offset(
          appearX, // 畫面中心 X 軸
          appearY, // 畫面頂部 Y 軸 (稍微在上方)
        ),
        velocity: Offset(
          (Random().nextDouble() - 0.5) * 5,
          0, // 初始 Y 軸速度為 0
        ),
        radius: radius,
        color: Colors.brown,
        groundFriction: groundFriction,
      ),
    );
    bubblesCreated++;
  }

  void _update(Duration duration) {
    setState(() {
      // Create new bubbles
      if (bubblesCreated < numberOfBubbles) {
        timeSinceLastBubble += duration.inMilliseconds / 1000;
        if (timeSinceLastBubble >= creationInterval) {
          _createBubble();
          timeSinceLastBubble = 0;
        }
      }

      // Update each bubble's position
      for (var bubble in bubbles) {
        _updateBubblePosition(bubble);

        _handleBoundaryCollisions(bubble);

        _handleArcCollisions(bubble);

        if (!isInsideCup(bubble)) {
          // If the bubble is outside the cup, force it back in
          bubble.position = Offset(
              bubble.position.dx.clamp(cupLeft + bubble.radius, cupRight - bubble.radius),
              bubble.position.dy.clamp(cupTop + bubble.radius, cupBottom));
          bubble.velocity = Offset(0, 0); // Stop movement
        } else {
          // 限制珍珠在杯子中的位置
          bubble.position = Offset(
            bubble.position.dx.clamp(cupLeft + bubble.radius, cupRight - bubble.radius),
            bubble.position.dy.clamp(cupTop + bubble.radius, cupBottom - bubble.radius),
          );
        }

        //再次確認邊界
         bubble.position = Offset(
            bubble.position.dx.clamp(cupLeft + bubble.radius, cupRight - bubble.radius),
            bubble.position.dy.clamp(cupTop + bubble.radius, cupBottom - bubble.radius),
          );
      }

      // Collision detection and resolution
      for (int iteration = 0; iteration < collisionResolutionIterations; iteration++) {
        for (int i = 0; i < bubbles.length; i++) {
          final bubble1 = bubbles[i];
          //只檢查還在畫面上的bubble
          if(!isInsideCup(bubble1)){
            continue;
          }
          for (int j = i + 1; j < bubbles.length; j++) {
            final bubble2 = bubbles[j];
            //只檢查還在畫面上的bubble
            if(!isInsideCup(bubble2)){
              continue;
            }

            //快速判斷是否有碰撞可能
            if ((bubble1.position.dx - bubble2.position.dx).abs() > bubble1.radius + bubble2.radius ||
                (bubble1.position.dy - bubble2.position.dy).abs() > bubble1.radius + bubble2.radius) {
              continue;
            }

            final distance = (bubble1.position - bubble2.position).distance;

            if (distance < bubble1.radius + bubble2.radius) {
              Offset collisionNormal = (bubble2.position - bubble1.position).normalize();

              double v1n = bubble1.velocity.dx * collisionNormal.dx + bubble1.velocity.dy * collisionNormal.dy;
              double v2n = bubble2.velocity.dx * collisionNormal.dx + bubble2.velocity.dy * collisionNormal.dy;

              double v1nAfter = v2n;
              double v2nAfter = v1n;

              bubble1.velocity += collisionNormal * (v1nAfter - v1n);
              bubble2.velocity += collisionNormal * (v2nAfter - v2n);

              double overlap = 0.5 * (bubble1.radius + bubble2.radius - distance);
              bubble1.position -= collisionNormal * overlap;
              bubble2.position += collisionNormal * overlap;
            }
          }
        }
      }
    });
  }

  void _updateBubblePosition(Bubble bubble) {
    // Add gravity effect
    bubble.velocity += Offset(0, gravity);

    // Add damping
    bubble.velocity *= dampingFactor;

    // 底部摩擦力
    if (bubble.position.dy >= cupBottom - bubble.radius) {
      bubble.velocity = Offset(bubble.velocity.dx * bubble.groundFriction, 0);
      bubble.position = Offset(bubble.position.dx, cupBottom - bubble.radius);

      // 增加一個小的隨機力，避免完全靜止不動
      final random = Random();
      bubble.velocity += Offset(
        (random.nextDouble() - 0.5) * 0.1, // 左右隨機力
        (random.nextDouble() - 0.5) * 0.1, // 上下隨機力
      );
    }

    bubble.position += bubble.velocity;

    // 最小速度限制
    if (bubble.velocity.distance < restingVelocityThreshold) {
      bubble.velocity = Offset.zero;
    }
  }

  void _handleBoundaryCollisions(Bubble bubble) {
    // Check if the bubble is outside of cupLeft and cupRight
    if (bubble.position.dx < cupLeft + bubble.radius) {
      bubble.position = Offset(cupLeft + bubble.radius, bubble.position.dy);
      bubble.velocity = Offset(-bubble.velocity.dx.abs() * bounceFactor, bubble.velocity.dy); // Bounce
      // 如果在左下角，給予一個往右上的速度
      if (bubble.position.dy > cupBottom - bubble.radius) {
        bubble.velocity = Offset(bubble.velocity.dx.abs() * 0.5, -bubble.velocity.dy.abs() * 0.5);
      }
    } else if (bubble.position.dx > cupRight - bubble.radius) {
      bubble.position = Offset(cupRight - bubble.radius, bubble.position.dy);
      bubble.velocity = Offset(bubble.velocity.dx.abs() * -bounceFactor, bubble.velocity.dy); // Bounce
      // 如果在右下角，給予一個往左上的速度
      if (bubble.position.dy > cupBottom - bubble.radius) {
        bubble.velocity = Offset(-bubble.velocity.dx.abs() * 0.5, -bubble.velocity.dy.abs() * 0.5);
      }
    }
  }

  // Arc Collision Detection
  void _handleArcCollisions(Bubble bubble) {
    double distanceToCenterX = bubble.position.dx - arcCenterX;
    double arcHeightAtBubbleX = arcCenterY + sqrt(max(0, arcRadius * arcRadius - pow(distanceToCenterX, 2)));

    // 檢查珍珠是否要掉入圓弧內 (珍珠頂部高於圓弧中心)
    if (bubble.position.dy - bubble.radius < arcCenterY) {
      // 檢查珍珠是否與圓弧發生碰撞
      if (bubble.position.dy + bubble.radius > arcHeightAtBubbleX && bubble.velocity.dy > 0) {
        // 調整珍珠速度和位置，模擬碰撞效果
        bubble.velocity = Offset(bubble.velocity.dx * 0.1, 0); // 減少 X 方向速度
        bubble.position = Offset(bubble.position.dx, arcHeightAtBubbleX - bubble.radius); // 更新位置
      }
    }

    // 檢查珍珠是否在圓弧下方並穿透圓弧
    if (bubble.position.dy + bubble.radius > arcCenterY) {
      if (bubble.position.dy > arcCenterY + arcRadius) {
        // 如果珍珠完全穿透圓弧，則强制將其拉回圓弧邊緣
        bubble.position = Offset(bubble.position.dx, arcCenterY + arcRadius - bubble.radius);
      } else if (bubble.position.dy + bubble.radius > arcHeightAtBubbleX) {
        //如果珍珠部分穿透圓弧，則限制珍珠位置在圓弧邊緣
        bubble.position = Offset(bubble.position.dx, arcHeightAtBubbleX - bubble.radius);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BubblePainter(
          bubbles: bubbles,
          cupLeft: cupLeft,
          cupRight: cupRight,
          cupTop: cupTop,
          cupBottom: cupBottom,
          arcCenterX: arcCenterX,
          arcCenterY: arcCenterY,
          arcRadius: arcRadius,
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double cupLeft;
  final double cupRight;
  final double cupTop;
  final double cupBottom;
  final double arcCenterX;
  final double arcCenterY;
  final double arcRadius;

  BubblePainter({
    required this.bubbles,
    required this.cupLeft,
    required this.cupRight,
    required this.cupTop,
    required this.cupBottom,
    required this.arcCenterX,
    required this.arcCenterY,
    required this.arcRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the bubbles
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = bubble.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(bubble.position, bubble.radius, paint);
    }

    // Draw the rectangular boundary
    final rectPaint = Paint()
      ..color = Colors.red.withOpacity(0.3) // Semi-transparent red
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTRB(cupLeft, cupTop, cupRight, cupBottom);
    // canvas.drawRect(rect, rectPaint);

    // Draw the arc
    final arcPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3) // Semi-transparent blue
      ..style = PaintingStyle.fill;

    // canvas.drawCircle(
    //   Offset(arcCenterX, arcCenterY),
    //   arcRadius,
    //   arcPaint,
    // );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}