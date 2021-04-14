import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '待辦清單'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class TodoItem {
  int id = new Random().nextInt(100);
  String description = '';
  bool done = false;
  TodoItem(String description) {
    this.description = description;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController myController = new TextEditingController();
  List<TodoItem> list = [];
  String dropdownValue = '全部';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  bool filterList(item) {
    if (dropdownValue == '完成') {
      return item.done;
    } else if (dropdownValue == '未完成') {
      return !item.done;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<TodoItem> filteredList = list.where(filterList).toList();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          DropdownButton<String>(
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['全部', '完成', '未完成']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Container(
            height: 500,
            child: ListView.builder(
              itemCount: filteredList.length,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              itemBuilder: (BuildContext context, int index) {
                var container = Container(
                  color: Colors.red,
                );
                return Dismissible(
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      filteredList[index].description,
                      style: TextStyle(
                          decoration: filteredList[index].done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                    value: filteredList[index].done,
                    onChanged: (newValue) {
                      setState(() {
                        filteredList[index].done = newValue;
                      });
                    },
                  ),
                  background: container,
                  key: ValueKey<int>(filteredList[index].id),
                  onDismissed: (DismissDirection direction) {
                    setState(() {
                      int realIdx = list.indexWhere(
                          (element) => element.id == filteredList[index].id);
                      list.removeAt(realIdx);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ConfirmAction action =
              await confirmDialog(context, myController);
          if (action == ConfirmAction.ACCEPT) {
            setState(() {
              list.add(new TodoItem(myController.text));
            });
          }
          myController.clear();
        },
        tooltip: '新增項目',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

enum ConfirmAction { ACCEPT, CANCEL }

Future<ConfirmAction> confirmDialog(
    BuildContext context, TextEditingController textController) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, //控制點擊對話框以外的區域是否隱藏對話框
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('新增待辦項目'),
        content: TextField(
          autofocus: true,
          controller: textController,
          decoration: InputDecoration(hintText: '請輸入...'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('確認'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          ),
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          )
        ],
      );
    },
  );
}
