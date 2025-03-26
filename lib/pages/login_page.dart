import 'package:flutter/material.dart';
import 'package:my_first_flutter_project/const.dart';
import 'package:my_first_flutter_project/pages/home_page.dart'; // 引入 HomePage
import 'sign_in.dart'; // 引入 SignIn 頁面

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key); // 定義 LoginPage 類別，繼承自 StatefulWidget

  @override
  State<LoginPage> createState() => _LoginPageState(); // 創建 LoginPage 的狀態
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final logoWidth = screenWidth * 0.7; // logo 寬度為螢幕寬度的 70%
    final logoHeight = screenHeight * 0.4; // logo 高度為螢幕高度的 40%
    final buttonFontSize = screenWidth * 0.08; // 按鈕字體大小為螢幕寬度的 8%
    final labelFontSize = screenWidth * 0.05; // Label 字體大小為螢幕寬度的 5%

    return Scaffold(
      backgroundColor: backgroundColor, // 設定背景顏色
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/images/login_bubble.png', // 替換為你的圖片路徑
              fit: BoxFit.cover, // 設定圖片填滿畫面
            ),
          ),
          Positioned(
            top: screenHeight * 0.05, // 設定圖片距離頂部的距離
            left: (screenWidth - logoWidth * 0.8) * 0.5, // 設定圖片距離左邊的距離，使其居中
            child: Image.asset(
              'lib/images/tea_coin.png', // 替換為你的圖片路徑
              width: logoWidth * 0.8, // 設定圖片寬度
              height: logoHeight, // 設定圖片高度
            ),
          ),
          Center(
            child: Image.asset(
              'lib/images/logo.png', // 替換為你的圖片路徑
              width: logoWidth, // 設定圖片寬度
              height: logoHeight, // 設定圖片高度
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter, // 將子 Widget 對齊到底部中央
            child: FractionallySizedBox(
              widthFactor: 0.7, // 設定子 Widget 寬度為父 Widget 的 80%
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.22), // 設定子 Widget 與底部的距離
                child: ElevatedButton(
                  onPressed: () {
                    // 按鈕按下時的動作
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()), // 跳轉到 SignIn 頁面
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.6, screenHeight * 0.08), // 設定按鈕的最小寬度和高度
                    backgroundColor: Colors.brown, // 設定按鈕的背景顏色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ), // 設定按鈕的圓角
                  ),
                  child: Text(
                    '會員登入', // 按鈕上的文字
                    style: TextStyle(
                      fontSize: buttonFontSize, // 設定文字大小
                      color: Colors.white, // 設定文字顏色
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter, // 將子 Widget 對齊到底部中央
            child: FractionallySizedBox(
              widthFactor: 0.8, // 設定子 Widget 寬度為父 Widget 的 80%
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.17), // 設定子 Widget 與底部的距離
                child: GestureDetector(
                  onTap: () {
                    // Label 按下時的動作
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  },
                  child: Text(
                    '訪客登入', // Label 上的文字
                    style: TextStyle(
                      fontSize: labelFontSize, // 設定文字大小
                      color: Colors.grey, // 設定文字顏色
                      decoration: TextDecoration.underline, // 設定文字下劃線
                    ),
                    textAlign: TextAlign.center, // 設定文字居中
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