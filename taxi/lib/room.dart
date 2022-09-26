//空室を探すときに、一番人数が多い空室に入る文章を追加するべき
//(今はfor文で名前順で回してしまっているので、本当は3人いる部屋に優先して入室してほしいのに、誰もいない空室の方に入ってしまう可能性がある)
//ブラウザのページ削除を行った場合に、その人を退席処理するべき

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import "dart:async";
import 'meet.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}



class _RoomPageState extends State<RoomPage> {
  late String myindex;
  /*
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
  */

  /*
  joinOrCreateRoom：空き部屋への入室、もしくは、新たに部屋を作る(非同期処理)(1回)
  ↓結果待ち FutureBuilder
  StreamBuilder:入った部屋の情報を随時更新する。
  */
  @override
  Widget build(BuildContext context) {
    Timer? _timer;
    return FutureBuilder(
      future:joinOrCreateRoom(),
      builder:((context, snapshot) {
        if(snapshot.hasData){
          String roomid = snapshot.data as String;
          return StreamBuilder<DocumentSnapshot>(
            stream:FirebaseFirestore.instance.collection("rooms").doc(roomid).snapshots(),
            builder: ((context, AsyncSnapshot<DocumentSnapshot>snapshot2) {
              _timer?.cancel();
              if(snapshot2.hasData){
                Map<String,dynamic> map = snapshot2.data!.data() as Map<String,dynamic>;
                //masterユーザーのindex番号(何番の人か)が記録される
                int masterIndex = map["master"];
                //namesに待っている人全員の名前を格納して、名前が入ってる人がいたらその人数だけリストタイル状に表示
                List<Widget> names = [];
                for(String index in map["names"].keys){
                  String name = map["names"][index];
                  if(name!=""){
                    names.add(
                      ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.face),
                          ),
                          title: Text(name),
                        )
                    );
                  }
                }
                //(もしまだ4人満席じゃなければ)names(Widgetのリスト)に退席ボタンを追加
                if(names.length<4){
                  names.add(ElevatedButton(
                    child:Text("退席"),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection("rooms").doc(roomid).update(
                        {"names.$myindex":""}
                      );
                      Navigator.pop(context);
                    },
                  ));
                }
                
                //4人揃ったら3秒待機して、次の画面に遷移させて待ち合わせ場所を表示              
                else if(names.length==4){
                  names.add(Text("相乗りメンバーの最終確認中。画面をそのままにしてお待ちください。"));
                  if(myindex == "1" && map["spotid"]==""){
                    setMeetspot(roomid);
                  }
                  
                  _timer = Timer(Duration(seconds:3),((){
                    Navigator.pushReplacement(context,MaterialPageRoute(builder:((context) => MeetPage(roomid, myindex))));
                  }));

                  /*
                  Timer(Duration(seconds:3),(() {
                    if(names.length==4){
                      Navigator.push(context,MaterialPageRoute(builder:((context) => MeetPage())));
                    } else {
                      names.removeLast();
                      names.add(ElevatedButton(
                        child:Text("退席"),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection("rooms").doc(roomid).update(
                            {"names.$myindex":""}
                          );
                          Navigator.pop(context);
                        },
                      ));
                    }
                  }));
                  */

                  //Navigator.push(context,MaterialPageRoute(builder:((context) => MeetPage())));
                }   
                          
                return Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                  ),
                  body:Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: names,
                  ),)
                );
                
              }else{
                return Text("now loading...");
              }
            })
          );
        }else{
          return const Text("now loading...");
        }
      })
    );
  }
  
  
  //集合場所を設定する
  void setMeetspot(String roomid)async{
    int minmsnum = 999; //待ち合わせ場所のnumberの最小値を格納
    int msnum = 0;
    String vacantspot = "";  //numberが最小値である待ち合わせ場所のkey(String)を格納
    var meetspots = await FirebaseFirestore.instance.collection("meetspots").doc("counter").get();
    for(String meetspot in meetspots.data()!.keys){
      msnum = meetspots[meetspot];
      if(msnum <= minmsnum){
        minmsnum = msnum;
        vacantspot = meetspot;
      }
    }
    await FirebaseFirestore.instance.collection("meetspots").doc("counter").update(
      {"$vacantspot": minmsnum+1} //vacantspotを待ち合わせとして設定するのでそのvalueをプラス1
    );
    await FirebaseFirestore.instance.collection("rooms").doc(roomid).update(
            {"spotid":"$vacantspot"}
          );
  }

  List<String> getNames(AsyncSnapshot<DocumentSnapshot> snapshot){
    List<String> list = [];
    return list;
  }

  Future<String> joinOrCreateRoom() async {
    var rooms = await FirebaseFirestore.instance.collection("rooms").get();
    //全部屋を一つずつ調べて、空室があった場合入室する。
    for(var room in rooms.docs){
      var names = room.get("names");
      for(String index in names.keys){
        String name = names[index];
        if(name == ""){
          await FirebaseFirestore.instance.collection("rooms").doc(room.id).update(
            {"names.$index":"自分の名前"}
          );
          myindex = index;
          return room.id;
        }
      }
    }
    //空き部屋が一つもなかったので、新しく部屋を作って入室する。
    String uuid = const Uuid().v4().toString();
    await FirebaseFirestore.instance.collection("rooms").doc(uuid).set({
      "finish":{
        "1":true,
        "2":true,
        "3":true,
        "4":true
      },
      "master":1,
      "names":{
        "1":"自分の名前",
        "2":"",
        "3":"",
        "4":""
      },
      "spotid":""
    });
    myindex = "1";
    return uuid;
  }

  /*
  ////(部屋の中が満室じゃなかったら時用の)自分の名前を１度だけ追加してこのプログラムの中に用意した在室者リストに全員を追加
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
  */
}

