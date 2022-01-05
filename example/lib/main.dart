import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mih_syncro_http/mih_syncro_http.dart';

void main() {
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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  SynchronizedHttp syn = SynchronizedHttp();
  late TabController controller = TabController(length: 2, vsync: this);
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();
  TextEditingController textEditingController4 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            TabBar(
              controller: controller,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black87,
              tabs: [
                Tab(
                  text: "Stream Get",
                ),
                Tab(
                  text: "Synced Post",
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Text("Stream Get"),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            child: SingleChildScrollView(
                              child: StreamBuilder<Response>(
                                stream: syn
                                    .streamGet(Uri.parse(
                                        "https://jsonplaceholder.typicode.com/posts"))
                                    .asBroadcastStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    return Text(snapshot.error.toString());
                                  if (snapshot.hasData)
                                    return Text(jsonEncode(
                                        jsonDecode(snapshot.data!.body)));
                                  return CircularProgressIndicator();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Text("Stream Get"),
                        Expanded(
                          child: Container(
                            child: Column(
                              children: [
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller: textEditingController1,
                                ),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  controller: textEditingController2,
                                ),
                                TextField(
                                  controller: textEditingController3,
                                ),
                                TextField(
                                  controller: textEditingController4,
                                ),
                                ElevatedButton(
                                  child: Text("Submit"),
                                  onPressed: () {
                                    syn.post(
                                      Uri.parse(
                                          "https://jsonplaceholder.typicode.com/posts"),
                                      headers: {
                                        "Content-Type": "application/json"
                                      },
                                      body: {
                                        "userId": int.parse(
                                            textEditingController1.text),
                                        "id": int.parse(
                                            textEditingController2.text),
                                        "title": textEditingController3.text,
                                        "body": textEditingController4.text,
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
