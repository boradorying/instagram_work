import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
//import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Store1(),
        ),
        ChangeNotifierProvider(
          create: (context) => Store2(),
        )
      ],
      child: MaterialApp(
        theme: theme,
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;
  var data = [];
  var userImage;
  var userContent;

  saveData() async {
    var storage = await SharedPreferences.getInstance();
  }

  addMyData() {
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 5,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'park bora'
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  addData(a) {
    setState(() {
      data.add(a);
    });
  }

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));

    var result2 = jsonDecode(result.body);
    setState(() {
      data = result2;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram'),
        actions: [
          IconButton(
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                setState(() {
                  userImage = File(image.path);
                });
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Upload(
                          userImage: userImage,
                          setUserContent: setUserContent,
                          addMyData: addMyData,
                        )),
              );
            },
            icon: Icon(
              Icons.add_box_outlined,
            ),
          )
        ],
      ),
      body: [Home(data: data, addData: addData), Text('샵')][tab],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.shopping_bag_outlined,
              ),
              label: '샵'),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, this.data, this.addData}) : super(key: key);
  final data;
  final addData;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scroll = ScrollController();

  getMore() async {
    var result = await http
        .get(Uri.parse("https://codingapple1.github.io/app/more1.json"));
    var result2 = jsonDecode(result.body);
    widget.addData(result2);
  }

  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
        controller: scroll,
        itemCount: widget.data.length,
        itemBuilder: (c, i) {
          return Column(
            children: [
              widget.data[i]['image'].runtimeType == String
                  ? Image.network(widget.data[i]['image'])
                  : Image.file(widget.data[i]['image']),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Text(widget.data[i]['user']),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => Profile(),
                            ),
                          );
                        },
                      ),
                      Text('좋아요 ${widget.data[i]['likes']}'),
                      Text(widget.data[i]['date']),
                      Text(widget.data[i]['content']),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Text('로딩중....');
    }
  }
}

class Store2 extends ChangeNotifier {
  var name = 'park bora';
}

class Store1 extends ChangeNotifier {
  var followers = 0;
  var friend = true;
  var profileImage = [];

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    notifyListeners();
  }

  changeName() {
    if (friend == false) {
      followers++;
      friend = true;
    } else {
      followers--;
      friend = false;
    }

    notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.watch<Store2>().name),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 28,
            ),
            Text('팔로워${context.watch<Store1>().followers}명'),
            ElevatedButton(
              onPressed: () {
                context.read<Store1>().changeName();
              },
              child: Text('팔로우'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<Store1>().getData();
              },
              child: Text('불러오기'),
            ),
          ],
        ));
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.userImage, this.setUserContent, this.addMyData})
      : super(key: key);
  final userImage;
  final setUserContent;
  final addMyData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                addMyData();
              },
              icon: Icon(Icons.send))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: 500,
              child: Image.file(
                userImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text('이미지 업로드 화면'),
          TextField(
            onChanged: (text) {
              setUserContent(text);
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
