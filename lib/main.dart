import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:new_test_chat/register.dart';
import 'package:new_test_chat/login.dart';
import 'package:new_test_chat/save_data.dart';
import 'chats.dart';

void main()async {
  runApp( MyHomePage());
  await Firebase.initializeApp();
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool? loggedIn=false;
  @override
  void initState() {
    getCurrentState();
    super.initState();
  }
  getCurrentState()async{
    await SaveData.getLoggedIN().then((value) {
      setState(() {
        if(value!=null) {
          loggedIn = value;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.dark(),
      home: loggedIn==null?blackScreen():loggedIn!?Chats():StartUp(),
    );
  }

}
class blackScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class StartUp extends StatefulWidget {

  @override
  _StartUpState createState() => _StartUpState();
}

class _StartUpState extends State<StartUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding:  EdgeInsets.all(25),
                child: TypewriterAnimatedTextKit(
                  text: ["Flutter Chat App"],
                  textStyle: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),
                  speed: Duration(milliseconds: 100),
                  repeatForever: false,
                  totalRepeatCount: 1,
                )
            ),
            Hero(
              tag: "hero",
              child: Material(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: MaterialButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return Login();
                    }));
                  },
                  elevation: 8,
                  minWidth: 380,
                  child: Text("login",style: TextStyle(fontSize: 25,color: Colors.white),),

                ),
              ),
            ),

            Hero(
              tag: "sign",
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RichText(

                    text: TextSpan(
                        children: [

                          TextSpan(text:  "if you are not registered please  ",style: TextStyle(fontSize: 17)),
                          TextSpan(
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return Register();
                              }));
                            },text: "Sign Up",style: TextStyle(color: Colors.blue,fontSize: 18,fontWeight:FontWeight.bold),
                          ),

                        ]
                    )

                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
