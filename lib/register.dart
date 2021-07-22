import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:new_test_chat/save_data.dart';
import 'package:new_test_chat/welcome_screen.dart';
import 'chat_screen.dart';
import 'chats.dart';

var ID;
class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
   String user="";
   String email="";String? otherError;
   String password="";String passwordError="";
  final controller=TextEditingController();
  final controller1=TextEditingController();
  final controller2=TextEditingController();
  bool spinner=false;
  bool obscure=true;
  final formEmaildKey=GlobalKey<FormState>();
  final formPasswordKey=GlobalKey<FormState>();
  final formUserKey=GlobalKey<FormState>();
@override
  void initState() {
    super.initState();

  }

  Future<String> bigID()async{
 final data=await _auth.currentUser;
 if(data!=null){
   ID=data.uid.toString();
 }
 return ID;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Padding(
      padding: const EdgeInsets.only(left:80),
      child: Text("Register",textAlign: TextAlign.center,style: TextStyle(fontSize: 30,
          foreground: Paint()
            ..shader=LinearGradient(
                colors: <Color>[Colors.cyan,Colors.blue])
                .createShader(Rect.fromLTWH(80.0, 0.0, 200.0, 70.0))
      ),
      ),
    ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                otherError!=null? Container(width: 400,height: 65,alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red,
                    ),
                  ),
                  child: Text(otherError!,
                    style: TextStyle(color: Colors.red,fontSize: 15,),textAlign: TextAlign.center,),
                ):SizedBox(),
                SizedBox(height: 15,),
                Form(key: formUserKey,
                  child: TextFormField(
                    validator: (value){
                      return value!.length<3&&value.length!=0?"The username must more than 3 chars":null;
                    },
                    cursorHeight: 20,controller:controller,
                    onChanged: (value){
                    setState(() {
                      otherError=null;
                      user=value;
                      formUserKey.currentState!.validate();
                    });},
                    style: TextStyle(
                      height: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(

                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        hintText: "username"
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                Form(key: formEmaildKey,
                  child: TextFormField(keyboardType: TextInputType.emailAddress,
                    validator: (value){
                      return value!=""?value!.contains("@email.com")||value.contains("@gmail.com")?
                      null:"your email must contain @gmail.com or @email.com":null;
                    },
                    cursorHeight: 20,controller:controller1,onChanged: (value){
                    setState(() {
                      otherError=null;
                      formEmaildKey.currentState!.validate();
                      email=value;
                    });
                     },
                    style: TextStyle(
                      height: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      hintText: "email",

                    ),
                  ),
                ),
                SizedBox(height: 15,),
                Form(key: formPasswordKey,
                  child: TextFormField(
                    validator: (value){
                      return value!.length<8 && value.length!=0?RegExp(r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(value)?
                      null:"your password must contain 8 chars, letters & numbers":null;
                    },
                    obscureText: obscure,
                    cursorHeight: 20,
                    controller:controller2,onChanged: (value){
                      setState(() {
                          otherError=null;
                        formPasswordKey.currentState!.validate();
                        password=value;
                      });},
                    style: TextStyle(
                      height: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(contentPadding: EdgeInsets.only(left: 40),
                      suffixIcon: password!=""?IconButton(
                        onPressed: (){setState(() {obscure=!obscure; print('yyyyyyyy{${password}}');});},
                        icon: Icon(obscure==true?Icons.visibility:Icons.visibility_off),):
                      SizedBox(),

                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        hintText: "password"
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Hero(
                  tag: "sign",
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [Colors.cyan,Colors.blue],

                        )
                    ),
                    child: MaterialButton(

                      minWidth: 400,
                      onPressed: ()async{
                        if(controller.text!="" && controller1.text!="" && controller2.text!=""){
                          setState(() {
                            spinner=true;
                          });

                          var userreg=await _auth.createUserWithEmailAndPassword(
                              email: email, password: password).catchError((e){
                            if(e.message=="The password is invalid or the user does not have a password."){
                              passwordError="The password is invalid";
                            }else{
                              otherError='The email or password is invalid\nplease try again.';
                            }
                          });

                          if(userreg!=null && user!=null) {
                            SaveData.saveUserEmail(email);
                            SaveData.saveUserName(user);
                            await _firestore.collection('users').add({
                              'email': email,
                              'name': user
                            });
                          }else{
                            print("user is null");
                          }
                          SaveData.saveLoggedIn(true);
                          if(userreg!=null){
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                Chats()
                            ));
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return Welcome( myName: user,);
                            }));

                          }
                          setState(() {
                            spinner=false;
                          });
                        }else{
                          setState(() {
                            otherError='The email or password or username field is empty\nplease try again.';
                          });
                        }

                      },
                      child: Text("Register",style: TextStyle(fontSize: 20,color: Colors.white),),
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
