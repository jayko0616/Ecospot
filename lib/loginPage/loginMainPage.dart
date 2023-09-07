import 'package:ecospot/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecospot/mainPage.dart';
import 'package:ecospot/loginPage/loginDB.dart';
import 'package:ecospot/loginPage/memberRegisterPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 자동 로그인 확인
// 토큰 있음 : 메인 페이지
// 토큰 없음 : 로그인 화면

class TokenCheck extends StatefulWidget {
  const TokenCheck({super.key});

  @override
  State<TokenCheck> createState() => _TokenCheckState();
}

class _TokenCheckState extends State<TokenCheck> {
  bool isToken = false;

  @override
  void initState() {
    super.initState();
    _autoLoginCheck();
  }

  void _autoLoginCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      setState(() {
        isToken = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //home: isToken ? MyAppPage() : LoginPage());
        home: MyAppPage());
  }
}

// 로그인 페이지
class LoginMainPage extends StatelessWidget {
  const LoginMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  // 자동 로그인 여부
  bool switchValue = true;

  // 아이디와 비밀번호 정보
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 로그인 설정
  void _setLogin(String username, String email) async {
    // 공유저장소에 유저 DB의 인덱스 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username); // 서버에서 받은 사용자 이름 정보
    await prefs.setString('email', email); // 서버에서 받은 사용자 이메일 정보
    print(username);
    print(email);
    // 추가된 코드: 모든 토큰 출력
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      String value = prefs.getString(key) ?? '';
      print('$key: $value');
    }
    // 메인 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyAppPage(),
      ),
    );
  }

  // 자동 로그인 설정
  void _setAutoLogin(String token) async {
    // 공유저장소에 유저 DB의 인덱스 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // 자동 로그인 해제
  void _delAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFCBCAC1),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 60.0),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.green,
                            width: 3,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(30.0),
                        image: const DecorationImage(
                            image: AssetImage(
                                'assets/images/ecospotNewLogo.png'))),
                  ),
                ),
                // ID 입력 텍스트필드
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    child: CupertinoTextField(
                      controller: usernameController,
                      placeholder: '아이디를 입력해주세요',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // 비밀번호 입력 텍스트필드
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 300,
                    child: CupertinoTextField(
                      controller: passwordController,
                      placeholder: '비밀번호를 입력해주세요',
                      textAlign: TextAlign.center,
                      obscureText: true,
                    ),
                  ),
                ),
                // 자동 로그인 확인 토글 스위치
                SizedBox(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '자동로그인 ',
                        style: TextStyle(
                            color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                      CupertinoSwitch(
                        // 부울 값으로 스위치 토글 (value)
                        value: switchValue,
                        activeColor: CupertinoColors.activeGreen,
                        onChanged: (bool? value) {
                          // 스위치가 토글될 때 실행될 코드
                          setState(() {
                            switchValue = value ?? false;
                          });
                        },
                      ),
                      Text('    '),
                      // 계정 생성 페이지로 이동하는 버튼
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemberRegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          '계정생성',
                          style: TextStyle(
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 로그인 버튼
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.teal)),
                      onPressed: () async {
                        final loginCheck = await login(
                            usernameController.text, passwordController.text);
                        print(loginCheck);

                        // 로그인 확인
                        if (loginCheck == null) {
                          print('로그인 실패');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('알림'),
                                content: Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
                                actions: [
                                  TextButton(
                                    child: Text('닫기'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          print('로그인 성공');
                          _setLogin(loginCheck.username, loginCheck.email);
                          // 자동 로그인 확인
                          if (switchValue == true) {
                            _setAutoLogin('auto');
                          } else {
                            _delAutoLogin();
                          }
                        }
                      },
                      child: Text('로그인'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
