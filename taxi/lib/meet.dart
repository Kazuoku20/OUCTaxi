//全員が集合し終わってfinishの各々がfalseになっていたらドキュメントを削除
//全員が集合し終わったら各々の画面をホーム画面に戻す
//ブラウザバックしたらエラーを吐くようにする


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taxi/room.dart';
import "dart:async";


class MeetPage extends StatefulWidget {
  MeetPage(this.roomid, this.myindex);
  final String roomid;
  final String myindex;

  @override
  _MeetPageState createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  @override
  Widget build(BuildContext context) {
    Timer? delete;
    return FutureBuilder(
      future:showMeetspot(widget.roomid),
      builder:((context, snapshot){
        if(snapshot.hasData){
          String ourspot = snapshot.data as String;
          return StreamBuilder<DocumentSnapshot>(
            stream:FirebaseFirestore.instance.collection("rooms").doc(widget.roomid).snapshots(),
            builder: ((context, AsyncSnapshot<DocumentSnapshot>snapshot2) {
              if(snapshot2.hasData){
                Map<String,dynamic> map = snapshot2.data!.data() as Map<String,dynamic>;
                int fincounter = 0;
                for(bool fin in map["finish"].values){
                  if(fin==false){
                    fincounter++;
                  }
                }
                if(fincounter==4){
                              Navigator.popUntil(context, (route) => route.isFirst);
                              //Navigator.push(context,MaterialPageRoute(builder: ((context) => MyHomePage())));
                              delete = Timer(Duration(seconds:3),((){
                                FirebaseFirestore.instance.collection("rooms").doc(widget.roomid).delete();
                              }));
                            }
                return Scaffold(
                  appBar: AppBar(
                                automaticallyImplyLeading: false,
                              ),
                              body:Center(
                                child:Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("みなさんの待ち合わせ場所は"),
                                    Text(ourspot),
                                    ElevatedButton(
                                      child:Text("相乗りメンバーが集合しました"),
                                      onPressed: () {
                                        recordFinish();
                                      },
                                    )
                                  ],
                                ),
                              )
                );
              } else {
                return Text("now loading...");
              }
            })
          );
        } else {
          return const Text("now loading...");
        }
      })
    );
  }

  //待ち合わせ場所が格納されたspotidのvalueを戻り値として返す
  Future<String> showMeetspot(roomid) async {
    var rooms = await FirebaseFirestore.instance.collection("rooms").doc(roomid).get();
    var meetspot = rooms.get("spotid");
    return meetspot;
  }

  void recordFinish() async {
    await FirebaseFirestore.instance.collection("rooms").doc(widget.roomid).update(
      {"finish.${widget.myindex}":false}
    );
  }
}


