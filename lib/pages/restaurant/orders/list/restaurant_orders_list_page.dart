import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RestaurantOrdersListPage extends StatefulWidget {
  @override
  _RestaurantOrdersListPageState createState() => _RestaurantOrdersListPageState();
}

class _RestaurantOrdersListPageState extends State<RestaurantOrdersListPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      //_con.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text('Restaurant orders list'),
      ),
    );
  }
}
