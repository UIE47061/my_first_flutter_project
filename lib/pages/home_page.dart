// home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'bubble.dart'; // 引入 bubble.dart
import 'dart:io' show Platform; // 導入 Platform 類別
import 'package:flutter/foundation.dart'; // 導入 kIsWeb

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key); // 定義 HomePage 類別，繼承自 StatefulWidget

  @override
  State<HomePage> createState() => _HomePageState(); // 創建 HomePage 的狀態
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StreamSubscription<dynamic>> _streamSubscriptions = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _streamSubscriptions.add(
      accelerometerEvents.listen((AccelerometerEvent event) {
        setState(() {
          // 處理加速度感應器數據
        });
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final imageWidth = screenWidth * 0.8; // 圖片寬度為螢幕寬度的 80%
    final imageHeight = screenHeight * 0.4; // 圖片高度為螢幕高度的 40%
    final buttonFontSize = screenWidth * 0.08; // 字體大小為螢幕寬度的 8%

    // 判斷是否為 iPhone X 以上的機型（有瀏海）
    final bool isIPhoneWithNotch = !kIsWeb && Platform.isIOS && MediaQuery.of(context).padding.top > 20;

    // 根據是否為 iPhone X 以上的機型調整頭像的頂部距離
    final double avatarTopPadding = isIPhoneWithNotch ? 50.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white, // 設定背景顏色
      body: Stack(
        children: [
          // 珍珠效果背景
          Positioned.fill(
            child: BubblePage(),
          ),
          // 使用者頭像
          Positioned(
            top: avatarTopPadding, // 調整頭像與頂部的距離
            left: 20.0, // 調整頭像與左側的距離
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("使用者資訊"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("姓名：小明"),
                          Text("Email：xiaoming@example.com"),
                          Text("會員等級：VIP"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("關閉"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 30, // 設定頭像的半徑
                backgroundImage: NetworkImage(
                    'https://example.com/user_avatar.jpg'), // 替換為你的使用者頭像 URL
                backgroundColor: Colors.grey, // 預設背景顏色
              ),
            ),
          ),
          // 其他 HomePage 的內容
          Center(
            child: Image.asset(
              'lib/images/bottle.png', // 替換為你的圖片路徑
              width: imageWidth, // 設定圖片寬度
              height: imageHeight, // 設定圖片高度
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter, // 將子 Widget 對齊到底部中央
            child: FractionallySizedBox(
              widthFactor: 0.8, // 設定子 Widget 寬度為父 Widget 的一半
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.15), // 設定子 Widget 與底部的距離
                child: ElevatedButton(
                  onPressed: () {
                    // 按鈕按下時的動作
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.7, screenHeight * 0.1), // 設定按鈕的最小寬度和高度
                    backgroundColor: Colors.brown, // 設定按鈕的背景顏色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ), // 設定按鈕的圓角
                  ),
                  child: Text(
                    '好想喝...', // 按鈕上的文字
                    style: TextStyle(
                      fontSize: buttonFontSize, // 設定文字大小
                      color: Colors.white, // 設定文字顏色
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}