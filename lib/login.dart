import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:new_test_chat/chat_screen.dart';
import 'package:new_test_chat/save_data.dart';
import 'package:new_test_chat/welcome_screen.dart';
import 'chat_screen.dart';
import 'chats.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final controller1=TextEditingController();final controller2=TextEditingController();
  final _auth=FirebaseAuth.instance;
  late String email; String password="";
  bool spinner=false;bool obscure=true;
  QuerySnapshot? _querySnapshot;
  final formEmailKey= GlobalKey<FormState>();final formPasswordKey= GlobalKey<FormState>();
  String? passwordError;String? otherErrors;



  Future getUser()async{
    return await _firestore
        .collection("users").where('email', isEqualTo: email).get()
        .then((value) {
      setState(() {
        _querySnapshot=value;
      });
      value.docs.forEach((element)async {
        User? data=await _auth.currentUser;
        if(data!=null){
          if(data.email==(_querySnapshot!.docs[0].data() as Map)["email"]){
            SaveData.saveUserName((_querySnapshot!.docs[0].data() as Map)["name"]);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 100),
          child: Text("login",textAlign: TextAlign.center,style: TextStyle(fontSize: 30,
              foreground: Paint()
                ..shader=LinearGradient(
                    colors: <Color>[Colors.cyan,Colors.blue])
                    .createShader(Rect.fromLTWH(100.0, 0.0, 200.0, 70.0))
          ),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              otherErrors!=null? Container(width: 400,height: 65,alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red,
                  ),
                ),
                child: Text(otherErrors!,
                  style: TextStyle(color: Colors.red,fontSize: 16,),textAlign: TextAlign.center,),
              ):SizedBox(),
              SizedBox(height: 20,),
              Form(key: formEmailKey,
                child: TextFormField(keyboardType: TextInputType.emailAddress,
                  validator: (value){
                    return value!.isNotEmpty?value.contains("@email.com")||value.contains("@gmail.com")?
                    null:"your email must contain @gmail.com or @email.com":null;
                  },
                  cursorHeight: 20,controller: controller1,
                  onChanged: (value){
                    setState(() {
                      otherErrors=null;
                      formEmailKey.currentState!.validate();
                    });

                    email=value;},
                  style: TextStyle(
                    height: 1
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius:BorderRadius.circular(40)),
                    hintText: "email",

                  ),
                ),
              ),
              SizedBox(height: 10,),
              Form(key: formPasswordKey,
                child: TextFormField(
                  validator: (value){
                    return passwordError!=null?passwordError:null;
                  },
                  obscureText: obscure,
                  cursorHeight: 20,
                  controller: controller2,onChanged: (value){
                    setState(() {
                      passwordError=null;
                      otherErrors=null;
                      formPasswordKey.currentState!.validate();
                      password=value;
                    });},
                  style: TextStyle(
                      height: 1
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 48),

                    suffixIcon: password!=""?IconButton(
                      onPressed: (){setState(() {obscure=!obscure; print('yyyyyyyy{${password}}');});},
                      icon: Icon(obscure==true?Icons.visibility:Icons.visibility_off),):
                    SizedBox(),

                    border: OutlineInputBorder(borderRadius:BorderRadius.circular(40)),
                    hintText: 'password',
                  ),
                ),
              ),
              SizedBox(height: 10,),

              Hero(
                tag: "hero",
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: [Colors.cyan,Colors.blue]
                    )
                  ),
                  child: MaterialButton(
                    onPressed: ()async{
                        try {
                          if (controller1.text != "" ||
                              controller2.text != "") {
                            setState(() {
                              spinner = true;
                            });

                            var user = await _auth.signInWithEmailAndPassword(
                                email: email, password: password).catchError((
                                e) {
                              setState(() {
                                if (e.message ==
                                    "The password is invalid or the user does not have a password.") {
                                  passwordError = "The password is invalid";
                                } else {
                                  otherErrors =
                                  'The email or password is invalid\nplease try again.';
                                }
                                formEmailKey.currentState!.validate();
                                formPasswordKey.currentState!.validate();
                              });
                              print("errrr: ${e.message}");
                            });
                            if (user != null) {
                              await SaveData.saveLoggedIn(true);
                              await SaveData.saveUserEmail(email);
                              await getUser();

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) =>
                                      Chats()
                                  ));
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return Welcome(
                                      myName: (_querySnapshot!.docs[0]
                                          .data() as Map)["name"],);
                                  }));
                            }

                            setState(() {
                              spinner = false;
                            });
                          } else {
                            setState(() {
                              otherErrors =
                              'The email or password field is empty\nplease try again.';
                            });
                          }
                        }catch(e){
                          print('error in login button, this is the error: $e');
                        }

                    },
                    child: Text("login",style: TextStyle(fontSize: 20),),

                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
