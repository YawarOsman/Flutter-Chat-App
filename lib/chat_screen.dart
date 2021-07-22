
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

var name;
var email;
class Chat_Screen extends StatefulWidget {
  String ChatRoomID;
  String userName;
 Chat_Screen({required this.ChatRoomID,required this.userName});

  @override
  _Chat_ScreenState createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  final _auth=FirebaseAuth.instance;
  final _firestore=FirebaseFirestore.instance;
  late String messageText;
  final controller=TextEditingController();
List<String> emailList=[];
  List<String> nameList=[];

  @override
  void initState() {
    super.initState();
    get();
    getUserName();
  }
 getUserName()async{
    await _firestore.collection("users").get().then((value) =>
    value.docs.forEach((element) {
      emailList.add(element.data()["email"]);
      nameList.add(element.data()["name"]);

    }));

    setState(() { });
  }


  void get()async{
    final data=await _auth.currentUser;
    if(data!=null){
      email=data.email;
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         StreamBuilder<QuerySnapshot>(
           stream: _firestore.collection('messages').doc(widget.ChatRoomID).collection('chats').orderBy('timestamp').snapshots(),
           builder: (context,snapshot){
             if(snapshot.hasData){
         final data=snapshot.data!.docs.reversed;
         List<messageUI> messageWidgetList=[];

         for(var message in data){

           final sender=(message.data() as Map<String, dynamic>)['email'];
           final content=(message.data() as Map<String, dynamic>)['content'];
            for(int i=0;i<emailList.length;i++){
              emailList[i]==sender?name=nameList[i]:"none";
            }

            var messageWidget=messageUI(sender:sender,content:content,name:name,isMe: sender==email);
            messageWidgetList.add(messageWidget );

         }

         return Expanded(
           child: Padding(
             padding: const EdgeInsets.all(8.0),
             child: ListView(
               reverse: true,
               children: messageWidgetList,
             ),
           ),
         );
       }
             return Center(child: CircularProgressIndicator(),);

         },
         ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: controller,
              onChanged: (value){messageText=value;},
              decoration: InputDecoration(
                suffixIcon: IconButton(icon: Icon(Icons.send,size: 30,),
                  onPressed: ()async{

                  if(controller.text!=""){   controller.clear();
                    await _firestore.collection("messages").doc(widget.ChatRoomID).collection('chats').add({
                      'email':email,
                      'content':messageText,
                      'timestamp':DateTime.now()
                    });

                  }

                  },),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                hintText: "enter you messages here"
              ),
            ),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}

class messageUI extends StatefulWidget {
  String? name;
  String? sender;
  String? content;
  bool isMe;

  messageUI({this.sender,this.content,this.name,required this.isMe});

  @override
  State<messageUI> createState() => _messageUIState();
}


class _messageUIState extends State<messageUI> {
  Color color=Colors.blue;

  @override
  Widget build(BuildContext context) {
    bool  popUpVisibility=false;
    var x;
    var y;
    _onTapDown(TapDownDetails details) {
      x = details.globalPosition.dx;
       y = details.globalPosition.dy;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: widget.isMe?MainAxisAlignment.end:MainAxisAlignment.start,
        children: [

          Flexible(
            child: Padding(
              padding:  EdgeInsets.only(left: widget.isMe?80:1,right: widget.isMe?1:80),
              child: GestureDetector(
                onTap: (){
                  Clipboard.setData(ClipboardData(text: widget.content));
                },
                onTapDown: (TapDownDetails details) {
                  _onTapDown(details);
                },

                onLongPress: ()async{

                  final select=await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(x-50, y-50, 10, 10),
                    items: [
                      PopupMenuItem(
                        child:  Row(
                          children: [
                            PopupMenuItem(
                              child: Text("copy",style: TextStyle(fontSize: 20),),
                              value: 0,
                              height: 30,
                            ),
                          ],
                        ),height: 30,
                      ),

                    ],
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                  if(select==0){
                    Clipboard.setData(ClipboardData(text: widget.content));
                  }


                 setState(() {  color=Colors.lightBlue.shade700;







                 // showMenu(
                 //     context: context, position: RelativeRect.fromLTRB(x-50, y-65, x, y), items: [
                 //   PopupMenuItem(
                 //     child: Container(color:Colors.red,
                 //       child: GestureDetector(
                 //           child: Text("copy"),
                 //         onTap: (){
                 //           Clipboard.setData(ClipboardData(text: widget.content));
                 //           print(widget.content);
                 //         },
                 //       ),
                 //     ),
                 //
                 //
                 //   ),
                 //
                 //
                 // ]).whenComplete(
                 //         (){
                 //       setState(() {
                 //         color=Colors.blue;
                 //       });
                 //     });


                 });
                },

                child: Material(
                  shape:  RoundedRectangleBorder(
                borderRadius:  widget.isMe?BorderRadius.only(
                bottomLeft: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(1)
                ):BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  topLeft: Radius.circular(1),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                ),
                  color: widget.isMe?color:Colors.cyan,

                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${widget.content}',style: TextStyle(fontSize: 18),),
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
