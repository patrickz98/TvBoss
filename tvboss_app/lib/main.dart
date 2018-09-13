import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'Curl.dart';
import 'CurlResponse.dart';
import 'EpgList.dart';

import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget
{
    @override
    Widget build(BuildContext context)
    {
        return new MaterialApp(
            title: 'TvBoss',
            theme: new ThemeData(
                primaryColor: Color(0xff2F363D),
            ),
            home: new MyHomePage(title: 'TvBoss'),
        );
    }
}

class _MyHomePageState extends State<MyHomePage>
{
    EpgList epgData;

    _MyHomePageState()
    {
        epgData = new EpgList([]);
    }

    void curl()
    {
        print("curl data");

        String url = "https://patrickz98.github.io/TvBoss/v1/2018/09/11/kabel_eins.json";

        http.get(url).then((http.Response response)
        {
            EpgList epgData = EpgList.parse(response.body);

            setState(()
            {
                this.epgData = epgData;
            });
        });

        //Curl.curlJson(url, curlResponse);
    }

    @override
    void initState()
    {
        super.initState();
        curl();
    }

    @override
    Widget build(BuildContext context)
    {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text(widget.title),
            ),
            body: Container(
                child:
            Stack(
                children: [
                    Positioned( // red box
                        child:  Container(
                            child: Text("Lorem ipsum"),
                            decoration: BoxDecoration(
                                color: Colors.red[400],
                            ),
                        ),
                        left: -24.0,
                        top: 24.0,
                    ),
                ],
            )
            )
//            body: new Container(
//                alignment: new Alignment(-1.0, 50.0),
//                width: 60.0,
//                height: 100.0,
//                color: Colors.orange,
////                child: new ListView.builder(
////                    itemCount: epgData.entries.length,
////                    scrollDirection: Axis.horizontal,
////                    itemBuilder: (BuildContext context, int index)
////                    {
////                        EpgData data = epgData.entries.elementAt(index);
////
////                        Duration duration = data.Stop.difference(data.Start);
////
////                        Text text = new Text(data.Title);
////                        return new Container(
////                            width: duration.inMinutes * 2.5,
////                            child: text,
////                            color: Color(Random.secure().nextInt(0xffffffff))
////                        );
////                    }
////                )
//            )
        );
    }
}

class MyHomePage extends StatefulWidget
{
    MyHomePage({Key key, this.title}) : super(key: key);

    final String title;

    @override
    _MyHomePageState createState() => new _MyHomePageState();
}
