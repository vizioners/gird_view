import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  createState() => new HomeState();
}

class HomeState extends State<Home> {

  ScrollController controller;
  final _all = <int>[];
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  int itemCount = 100;
  int itemDecreaseCount = 99;

  @override
  void initState() {
    super.initState();
    var arr = <int>[];
    for(int i  = 0; i < 30 ;i++){
      arr.add(itemCount);
      itemCount += 1;
    }
    _all.addAll(arr);
    controller = new ScrollController()..addListener(_scrollListener);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      startLoader();
    }
  }

  void startLoader() {
    setState(() {
      isLoading = !isLoading;
      fetchData();
    });
  }

  fetchData() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, onResponse);
  }

  void onResponse() {
    var arr = <int>[];
    for(int i  = 0; i < 30 ;i++){
      arr.add(itemCount);
      itemCount += 1;
    }
    setState(() {
      isLoading = !isLoading;
      _all.addAll(arr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          "Gird view pull refresh",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              },
              padding: EdgeInsets.all(8.0),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: new Stack(
          children: <Widget>[
            _buildSuggestions(),
            _loader(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    return new GestureDetector(
      child: new Card(
        elevation: 5.0,
        child: new Container(
          alignment: Alignment.center,
          child: new Text('Item $index'),
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            child: new CupertinoAlertDialog(
              title: new Column(
                children: <Widget>[
                  new Text("Girdview"),
                  new Icon(
                    Icons.favorite,
                    color: Colors.green,
                  )
                ],
              ),
              content: new Text("Selected Item $index"),
              actions: <Widget>[
                new FlatButton(onPressed: () {
                  Navigator.of(context).pop();
                },
                    child: new Text("OK")
                )
              ],
            )
        );
      },
    );
  }

  Widget _buildSuggestions() {
    return new GridView.builder(
        padding: const EdgeInsets.all(16.0),
        controller: controller,
        itemCount: _all.length,
        gridDelegate:
        new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3),
        itemBuilder: (context, index) {
          return _buildRow(_all[index]);
        });
  }

  Widget _loader() {
    return isLoading
        ? new Align(
      child: new Container(
        width: 70.0,
        height: 70.0,
        child: new Padding(
            padding: const EdgeInsets.all(5.0),
            child: new Center(child: new CircularProgressIndicator())),
      ),
      alignment: FractionalOffset.bottomCenter,
    )
        : new SizedBox(
      width: 0.0,
      height: 0.0,
    );
  }

  Future<List<int>> getNewData() async {
    var arr = List<int>();
    for(int i  = 0; i < 10 ;i++){
      arr.add(itemDecreaseCount);
      await Future.delayed(const Duration(milliseconds: 200));
      itemDecreaseCount -= 1;
      if(itemDecreaseCount == 0){
        break;
      }
    }
    arr = arr.reversed.toList();
    return arr;
  }

  Future<Null> _refresh() {
    return getNewData().then((arr) {
      setState(() {
        _all.insertAll(0, arr);
      });
    });
  }
}