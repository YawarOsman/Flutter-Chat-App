import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_test_chat/save_data.dart';
import 'chat_screen.dart';
import 'main.dart';


final FirebaseFirestore _firestore=FirebaseFirestore.instance;
final TextEditingController _searchController= TextEditingController();
 QuerySnapshot? _querySnapshot;
QuerySnapshot? _querySnapshot2;
final _auth=FirebaseAuth.instance;

class Chats extends StatefulWidget {

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {

   var myName;
   var myEmail;
   getSnapshot()async{
    final data=await _firestore.collection("users");
    final checkNull=await _auth.currentUser;
    if(checkNull!=null){
      myEmail=checkNull.email.toString();
    }
    if(_searchController.text!=""){
       await data.where('name',isEqualTo:_searchController.text).get()
          .then((value) {
        setState(() {
          _querySnapshot=value;
        });
      });
    }else{
      await _firestore.collection("messages").where('chatRoomID',arrayContains: myEmail).get().then((value) {
          setState(() {
            _querySnapshot2=value;

          });

     });
    }

  }


  Widget searchList(){
   if(_searchController.text!=""){
     return Expanded(
       child: _querySnapshot!=null?ListView.builder(
           itemCount: _querySnapshot!.docs.length,
           itemBuilder: (BuildContext context,int index){
             return ListBuilder(
                 userName: (_querySnapshot!.docs[index].data() as Map)["name"],
                 email: (_querySnapshot!.docs[index].data() as Map)["email"]
             );
           }
       ):SizedBox(),
     );
   }else{
    return Expanded(
       child: _querySnapshot2!=null?ListView.builder(
           itemCount: _querySnapshot2!.docs.length,
           itemBuilder: (BuildContext context,int index){
             return ListBuilder(
                 userName: (_querySnapshot2!.docs[index].data() as Map)["users"][1]!=myName?
                 (_querySnapshot2!.docs[index].data() as Map)["users"][1]:
                 (_querySnapshot2!.docs[index].data() as Map)["users"][0],

                 email:(_querySnapshot2!.docs[index].data() as Map)["chatRoomID"][1]!=myEmail?
                 (_querySnapshot2!.docs[index].data() as Map)["chatRoomID"][1]:
                 (_querySnapshot2!.docs[index].data() as Map)["chatRoomID"][0]
             );
           }
       ):SizedBox(),
     );
   }
  }


@override
  void initState() {
     getUName();
     getSnapshot();
     super.initState();


  }
  getUName()async{
    myName =await SaveData.getUserName();
    FocusScope.of(context).requestFocus( FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(myName??''),
           leading: Container(padding: EdgeInsets.all(5),
             child: Material(child: Icon(Icons.person,size: 20,),
               borderRadius: BorderRadius.circular(50),),
           ),

          actions: [IconButton(icon: Icon(Icons.logout),
            onPressed: (){
            _auth.signOut();Navigator.pop(context);
            SaveData.saveLoggedIn(false);
            SaveData.saveUserEmail('');
            _searchController.clear();
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return StartUp();
            }));
            },),],),

        body: Padding(padding: const EdgeInsets.only(top: 5,left: 15,right: 15,),
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Container(
                    width: 400,height: 40,decoration: BoxDecoration(color: Colors.white10,
                      borderRadius: BorderRadius.circular(20)
                    ),
                ),
                  ),
                  SizedBox(width: 390,
                    child: TextField(
                    onChanged: (value){
                      getSnapshot();
                    },
                      controller:_searchController,
                      cursorHeight: 20,
                      style: TextStyle(
                      fontSize: 18,
                    ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(icon: Icon(Icons.close),onPressed: (){setState(() {
                          _searchController.clear();
                        });},),

                      ),
                    ),
                  ),
                ],
              ),SizedBox(height: 10,),
                   searchList()
            ],
          ),
        ),
      ),
    );

  }
}
Future<String> getUserName()async{
  String? uName =await SaveData.getUserName();
  return uName!;

}
getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}


var ChatRoomID;
void chatConversations(String userName,String email)async{
  String myName=await getUserName();
  String myEmail=await _auth.currentUser!.email.toString();
   ChatRoomID=getChatRoomId(email,myEmail);
  List<String> users=[
    myName ,userName
  ];
  List<String> RoomID=[
    myEmail ,email
  ];
  Map<String,dynamic> ChatRoomMap={
    'users':users,
    'chatRoomID':RoomID
  };
  createChatRoom(ChatRoomID, ChatRoomMap);

}
void createChatRoom(String chatRoomID,chatRoomMap){
  _firestore.collection('messages').doc(chatRoomID).set(chatRoomMap).catchError((e){
    print(e.toString());
  });
}


class ListBuilder extends StatelessWidget {
  String userName;
  String? email;
  ListBuilder({required this.userName,this.email});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(_querySnapshot!=null||_querySnapshot2!=null){
          chatConversations(userName,email!);
          Navigator.push(context, MaterialPageRoute(
              builder: (context){
                return Chat_Screen(ChatRoomID: ChatRoomID,userName:userName);
              }));
        }
        else{
          print("query Snapshot is null:$_querySnapshot and this is 2:$_querySnapshot2");
        }
      },
      child: ListTile(
          title:Row(
            children: [
              Padding(
                padding:   EdgeInsets.only(right: 15),
                child: Container(
                  child: Icon(Icons.person,color: Colors.white,size: 40,),
                  decoration: BoxDecoration(color: Colors.white24,
                      borderRadius: BorderRadius.circular(50)
                  ),
                ),
              ),
             Column( crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(userName!=null?userName:'',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),SizedBox(height: 5,),
                 Text(email!=null?email!:'',style: TextStyle(fontSize: 15,color: Colors.grey),),
               ],
             )

            ],
          )
      ),
    );
  }
}
