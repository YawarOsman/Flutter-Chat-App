import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  String myName;
  Welcome({required this.myName});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Container(width: 150,height: 150,
              child: CircleAvatar(
                child: Icon(Icons.person,size: 130,),
              ),
            ),
            Text("You are now signed in as \n${widget.myName}",textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                        colors: [Colors.cyan,Colors.blue]
                    )
                ),
                child: MaterialButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("CONTINUE",style: TextStyle(fontSize: 20),),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
