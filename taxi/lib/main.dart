import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taxi/room.dart';


Future<void> main() async{
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA3UBHPskZJaDseTVo_xGBau8RVnR2C_Go",
      authDomain: "ainori-423ec.firebaseapp.com",
      projectId: "ainori-423ec",
      storageBucket: "ainori-423ec.appspot.com",
      messagingSenderId: "930632927513",
      appId: "1:930632927513:web:4d6e6a50d02dc290461d88",
      measurementId: "G-FNBW1XSDCW"
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
   
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  bool isPress = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }


  List<String>members=["佐藤栄作","奥山和樹","吉岡晃汰","武市和真"];

  List<Widget> memberlist(){
    List<Widget> result = [];
    //人の表示
    if(isPress){
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
    }else{
      result.add(Text("ボタンを押すと相乗り募集に追加されます"));
    }
    //募集ボタン
    result.add(
            ElevatedButton(
              child: Text("相乗りを募集する"),
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: ((context) => RoomPage())));
              },
            ));
    result.add(
      ElevatedButton(onPressed: () async {
        await FirebaseFirestore.instance.collection("users").add({"name":"よしおか","number":2020371});
      }, child: Text("テスト"))
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: memberlist(),
        ),
      ),
    );
  }
}
