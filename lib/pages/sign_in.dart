import 'package:flutter/material.dart';
import '/const.dart';
import 'home_page.dart'; // 確保導入 HomePage

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 在這裡處理返回邏輯
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return false; // 阻止默認的返回行為
        } else {
          // 處理無法返回的情況
          return true; // 允許默認的返回行為（如果需要）
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: 40.0,
              left: 20.0,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // 返回上一頁
                  } else {
                    // 處理無法返回的情況，例如顯示訊息或執行其他操作
                    print('無法返回上一頁');
                  }
                },
              ),
            ),
            Center(
              child: SingleChildScrollView( // 讓畫面在小螢幕上可以滾動
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // 應用程式標題
                    Text(
                      '歡迎登入',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    SizedBox(height: 48.0),

                    // Email 輸入框
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '電子郵件',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.0),

                    // 密碼輸入框
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '密碼',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true, // 隱藏密碼
                    ),
                    SizedBox(height: 24.0),

                    // 登入按鈕
                    ElevatedButton(
                      onPressed: () {
                        // 這裡處理登入邏輯
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text('登入'),
                    ),
                    SizedBox(height: 32.0),

                    // 分隔線
                    Row(
                      children: <Widget>[
                        Expanded(child: Divider(thickness: 1.0)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '或',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 1.0)),
                      ],
                    ),
                    SizedBox(height: 32.0),

                    // Google 登入按鈕
                    OutlinedButton.icon(
                      onPressed: () {
                        // 這裡處理 Google 登入邏輯
                      },
                      icon: Image.network(
                        'https://img.icons8.com/color/32/000000/google-logo.png', // Google Logo 網路圖片
                        height: 24.0,
                      ),
                      label: Text('使用 Google 登入'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: TextStyle(fontSize: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // Facebook 登入按鈕
                    OutlinedButton.icon(
                      onPressed: () {
                        // 這裡處理 Facebook 登入邏輯
                      },
                      icon: Image.network(
                        'https://img.icons8.com/color/32/000000/facebook-new.png', // Facebook Logo 網路圖片
                        height: 24.0,
                      ),
                      label: Text('使用 Facebook 登入'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: TextStyle(fontSize: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
