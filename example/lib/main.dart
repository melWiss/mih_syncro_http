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

class _MyHomePageState extends State<MyHomePage> {
  SynchronizedHttp syn = SynchronizedHttp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            // Text("Future Get"),
            // Expanded(
            //   child: Container(
            //     padding: EdgeInsets.all(8),
            //     child: SingleChildScrollView(
            //       child: FutureBuilder<Response>(
            //         future: syn.get(Uri.parse(
            //             "https://jsonplaceholder.typicode.com/posts")),
            //         builder: (context, snapshot) {
            //           if (snapshot.hasError)
            //             return Text(snapshot.error.toString());
            //           if (snapshot.hasData)
            //             return Text(
            //                 jsonEncode(jsonDecode(snapshot.data!.body)));
            //           return CircularProgressIndicator();
            //         },
            //       ),
            //     ),
            //   ),
            // ),
            Text("Stream Get"),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: StreamBuilder<Response>(
                    stream: syn.streamGet(Uri.parse(
                        "https://jsonplaceholder.typicode.com/posts")),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Text(snapshot.error.toString());
                      if (snapshot.hasData)
                        return Text(
                            jsonEncode(jsonDecode(snapshot.data!.body)));
                      return CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
