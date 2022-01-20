import 'package:delivery/pages/client/products/detail/client_products_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientProductsDetailPage extends StatefulWidget {
  @override
  _ClientProductsDetailPageState createState() => _ClientProductsDetailPageState();
}

class _ClientProductsDetailPageState extends State<ClientProductsDetailPage> {

  ClientProductsDetailController _con = new ClientProductsDetailController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Text(
        'Modal'
      ),
    );
  }

  void refresh(){
    setState(() {

    });
  }
}
