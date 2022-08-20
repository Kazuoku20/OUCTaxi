import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}



class _RoomPageState extends State<RoomPage> {
  String myname = "奥山";
  List<String>members=[];
  List<Widget> memberlist(){
    List<Widget> result = [];
    //人の表示
    for(int i = 0 ; i < members.length ; i++){
      result.add(
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.face),
            ),
            title: Text(members[i]),
          )
      );
    }
    return result;
  } 

  @override
  Widget build(BuildContext context) {
    joinandcreateroom();
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("rooms").snapshots(),
      builder: (context,AsyncSnapshot<QuerySnapshot>snapshot){
        return Scaffold(
          appBar: AppBar(),
          body:Center(
            child:test(snapshot)
          )
        );
      }
    );
  }

  ////(部屋の中が満室じゃなかったら時用の)自分の名前を１度だけ追加して、このプログラムの中に用意した在室者リストに全員を追加
  void joinandcreateroom(){
    //FirebaseFirestore.instance.collection("rooms").snapshots();
      String roomID = findAndCreateRoom();
      joinRoom(roomID);
  }

  Widget test(AsyncSnapshot<QuerySnapshot> snapshot){
    if(snapshot.hasData){
      //String roomID = findAndCreateRoom(snapshot);
      //joinRoom(roomID);
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: memberlist(),
      );
    }else{
      return Text("読み込み中");
    }
  }

  //空き部屋を探す処理
  //もし、空き部屋がなかった場合、新たに部屋を作成する処理
  String findAndCreateRoom(){
    //AsyncSnapshot<QuerySnapshot> snapshot
    FirebaseFirestore.instance.collection("rooms").doc().get().then((room) {
      print(room);
      final names = room.get("names");
      bool full = true;
      for(var n in names.values){
        if(n == ""){
          full = false;
          break;
        }
      }
      if(!full){
        //部屋の中に入る（処理終了）
        return room.id;
      }
    });
    /*
    for(var room in ){
      //snapshot.data!.docs
      final names = room.get("names");
      bool full = true;
      for(var n in names.values){
        if(n == ""){
          full = false;
          break;
        }
      }
      if(!full){
        //部屋の中に入る（処理終了）
        return room.id;
      }
    }
    */
    //全部満室だったので部屋を作成する
    String uuid = Uuid().toString();
    FirebaseFirestore.instance.collection("rooms").doc(uuid).set({
      "master":1,
      "names":{
        "1":"",
        "2":"",
        "3":"",
        "4":""
      }
    });
    return uuid;
  }

  //(部屋の中が満室じゃなかったら時用の)自分の名前を１度だけ追加する(在室者のリストを表示は次に回す)
  void joinRoom(String roomID)async{
    var names;
    await FirebaseFirestore.instance.collection("rooms").doc(roomID).get().then((value) {names = value.get("names");});
    print(names);
    bool write = false;
    for(String n in names.keys){
            String name = names[n];
            if(name==""){
              int i = int.parse(n);
              FirebaseFirestore.instance.collection("rooms").doc(roomID).update({
                "names.${i}": myname 
              });
              break;
            }
    }
  }

  //メンバーを表示
  void showMember(String roomID)async{
    var names;
    await FirebaseFirestore.instance.collection("rooms").doc(roomID).get().then((value) {names = value.get("names");});
    for(String n in names.keys){
      String name = names[n];
      if(name!=""){
        members.add(name);   //n(names配列のvalue)が空欄じゃなかったらnをmembersリスト(画面に表示する人を格納している配列)に追加
      }
    }
  }
}

