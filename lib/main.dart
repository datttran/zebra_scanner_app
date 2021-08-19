import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zebra_trackaware/logics/APIlogic.dart';
import 'package:zebra_trackaware/size_config.dart';
import 'package:zebra_trackaware/utils/colorstrings.dart';
import 'package:zebra_trackaware/utils/strings.dart';
import 'package:zebra_trackaware/utils/utils.dart';

import 'constants.dart';
import 'globals.dart' as globals;
import 'home.dart';
import 'logics/pageRoute.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  //final emailController = TextEditingController(text: 'teresaf');
  //final passwordController = TextEditingController(text: 'Teresaf11@');
  final emailController = TextEditingController(text: globals.isTesting ? 'testtest' : '');
  final passwordController = TextEditingController(text: globals.isTesting ? 'testtest1' : '');
  var userFetchCount = 0;
  bool rememberMe = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    SystemChrome.setEnabledSystemUIOverlays([]);

    final email = new Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPixel * .8, horizontal: 5),
          child: TextFormField(
            style: TextStyle(color: HexColor(ColorStrings.emailPwdTextColor), fontSize: 16),
            autofocus: false,
            decoration:
                InputDecoration.collapsed(focusColor: HexColor(ColorStrings.emailPwdTextColor), hintText: "Enter username", hintStyle: TextStyle(color: Colors.white70.withOpacity(0.2), fontSize: 15)),
            validator: (value) {
              if (value!.isEmpty) {
                return Strings.userNameValidationMessage;
              }
              return null;
            },
            controller: emailController,
            focusNode: _emailFocus,
          ),
        ));

    final userNameBlock = GestureDetector(
        onTap: () {
          _passwordFocus.unfocus();
          FocusScope.of(context).requestFocus(_emailFocus);
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(width: 5),
                  Text(
                    Strings.usernameCaps,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: HexColor(ColorStrings.emailPwdTextColor),
                      fontSize: verticalPixel * 1.8,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
              ),
              email
            ],
          ),
        ));

    final password = Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPixel * .8, horizontal: 4),
          child: TextFormField(
            focusNode: _passwordFocus,
            autofocus: false,
            style: TextStyle(color: HexColor(ColorStrings.emailPwdTextColor), fontSize: 17),
            controller: passwordController,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value!.isEmpty) {
                return Strings.passwordValidationMessage;
              }
              return null;
            },
            obscureText: true,
            decoration: InputDecoration.collapsed(hintText: "Enter Password", hintStyle: TextStyle(color: Colors.white70.withOpacity(0.2), fontSize: 15)),
          ),
        ));

    final passwordBlock = GestureDetector(
        onTap: () {
          _emailFocus.unfocus();
          FocusScope.of(context).requestFocus(_passwordFocus);
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(width: 5),
                  Text(
                    Strings.passwordCaps,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: HexColor(ColorStrings.emailPwdTextColor),
                      fontSize: verticalPixel * 1.8,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              ),
              password
            ],
          ),
        ));

    _onLoginButtonPressed() async {
      if (_formKey.currentState!.validate()) {
        //terms and conditions changed to remember me
        /* if (!rememberMe) {
          showDemoDialog<String>(
            context: context,
            child: CupertinoAlertDialog(
              title: const Text(
                  'By logging in, you agree to Terms and Conditions for using Trackaware'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('Ok'),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Discard');
                  },
                )
              ],
            ),
          );
          return;
        } */
        FocusScope.of(context).requestFocus(FocusNode());
        print(emailController.text);
        globals.user = emailController.text;
        print(globals.user);
        var result = await userLogin(emailController.text, passwordController.text);

        if (result == 'Valid User') {
          Navigator.of(context).push(toPage(Home()));
        } else {
          print(result);
        }
        if (!rememberMe) {
          emailController.text = '';
          passwordController.text = '';
        }

        //
      }
    }

    return Material(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
            key: _formKey,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xff2C2C34), Color(0xff171721)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Stack(children: [
                Text(
                  'T R A C K   '
                  ' A W A R E',
                  style: TextStyle(
                    fontSize: verticalPixel * 25,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(26.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 7,
                            ),

                            /*SvgPicture.asset(
                                    "assets/logo.svg",
                                    height: verticalPixel*20,
                                    color: Colors.white70,
                                  ),*/
                          ],
                        )),
                    SizedBox(
                      height: verticalPixel * 7,
                    ),
                    Column(
                      children: [
                        userNameBlock,
                        passwordBlock,
                        Container(
                          width: double.infinity,
                          //height: 30,
                          //color: Colors.greenAccent,
                          margin: EdgeInsets.fromLTRB(0, 8, 40, 8),
                          child: CheckboxListTile(
                            activeColor: Colors.indigoAccent.withOpacity(.5),
                            title: Text(
                              "Remember me",
                              style: TextStyle(color: Colors.white70),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: rememberMe,
                            onChanged: (value) {
                              print('tap');
                              setState(() {
                                rememberMe = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: verticalPixel * 1,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _onLoginButtonPressed();
                          },
                          child: Container(
                              width: double.infinity,
                              height: 60,
                              //margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xff621fff), Color(0xff640eba)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  shape: BoxShape.rectangle,
                                  border: Border.all(color: Colors.transparent, width: 1.0),
                                  borderRadius: BorderRadius.circular(0)),
                              child: Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    Strings.loginText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: HexColor(ColorStrings.loginTextColor)),
                                  ))),
                        ),
                        /*GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/SignUpScreen');
                                },
                                child: Container(
                                    width: double.infinity,
                                    height: 60,
                                    //margin: EdgeInsets.fromLTRB(40, 8, 40, 0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [Color(0xffe0e0ff).withOpacity(.8), Color(0xffffffff).withOpacity(1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                        shape: BoxShape.rectangle,
                                        border: Border.all(color: Colors.transparent, width: 1.0),
                                        borderRadius: BorderRadius.circular(0)),
                                    child: new Material(
                                        color: Colors.transparent,
                                        child: Text(
                                          Strings.SIGN_UP,
                                          textAlign: TextAlign.center,
                                        ))),
                              ),*/
                      ],
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/ForgotPwdScreen');
                        },
                        child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(30, 16, 40, 0),
                            child: Text(
                              Strings.forgotpassword,
                              style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                            ))),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(style: TextStyle(fontSize: 12), children: [
                              TextSpan(text: 'By Logging In, you agree to the ', style: TextStyle(color: Colors.white70)),
                              TextSpan(
                                text: "Terms of Use",
                                style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    print('tapped');
                                  },
                              ),
                              TextSpan(text: ' for ', style: TextStyle(color: Colors.white70)),
                              TextSpan(text: 'Sensitel Service.', style: TextStyle(color: Colors.white)),
                            ])))
                  ],
                ),
              ]),
            )),
      ),
    );
  }
}