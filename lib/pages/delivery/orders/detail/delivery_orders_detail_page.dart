import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/pages/delivery/orders/detail/delivery_orders_detail_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:delivery/utils/relative_time_util.dart';
import 'package:delivery/widgets/no_data_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DeliveryOrdersDetailPage extends StatefulWidget {

  Order order;

  DeliveryOrdersDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _DeliveryOrdersDetailPageState createState() => _DeliveryOrdersDetailPageState();
}

class _DeliveryOrdersDetailPageState extends State<DeliveryOrdersDetailPage> {

  DeliveryOrdersCreateController _con = DeliveryOrdersCreateController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh, widget.order);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${_con.order != null ?_con.order!.id ?? '' : ''}'),
        actions: [
          Container(
            margin: EdgeInsets.only(top: 17, right: 15),
            child: Text(
              'Total: ${_con.total}\$',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: SingleChildScrollView(
          child: Column(
              children: [
                Divider(
                  color: Colors.grey[400],
                  endIndent: 30, // margen derecho
                  indent: 30, // margen izquierdo
                ),
                SizedBox(height: 10,),
                _textData('Recoger en: ',
                    _con.order != null
                    ? '${_con.order!.restaurant!.name!} (${_con.order!.store!.address ?? ''})'
                    : ''),
                _textData('Cliente:', _con.order != null
                    ? '${_con.order!.client!.name} ${_con.order!.client!.lastname}'
                    : ''),
                _textData('Entregar en:', _con.order != null
                    ? '${_con.order!.address!.address}'
                    : ''),
                _textData(
                    'Fecha de pedido:',
                    _con.order != null
                        ? '${RelativeTimeUtil.getRelativeTime(_con.order!.timestamp ?? 0)}'
                        : ''
                ),
                _con.order != null && _con.order!.status == 'DESPACHADO'
                ? _buttonAccept()
                  : _con.order != null && _con.order!.status != 'ENTREGADO'
                    ? _buttonNext()
                : Container(),
              ],
          ),
        ),
      ),
      body:  _con.order != null
          ? (_con.order!.products.length > 0)
            ? ListView(
              children: _con.order!.products.map((Product product) {
                return _cardProduct(product);
              }).toList())
          : NoDataWidget(text: 'Ningun producto agregado')
        : NoDataWidget(text: 'Ningun producto agregado'),
    );
  }

  Widget _cardProduct(Product product){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _imageProduct(product),
          SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10,),
              Text(
                'Cantidad: ${product.quantity ?? 0}',
                style: TextStyle(
                    fontSize: 13
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageProduct(Product product){
    return Container(
      width: 50,
      height: 50,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.grey[200]
      ),
      child: FadeInImage(
        image:  product.image1 != null
            ? NetworkImage(product.image1!)
            : AssetImage('assets/img/no-image.png') as ImageProvider,
        fit: BoxFit.contain,
        fadeInDuration: Duration(milliseconds: 50),
        placeholder: AssetImage('assets/img/no-image.png'),
      ),
    );
  }

  Widget _textData(String title, String content){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        title: Text(
          title
        ),
        subtitle: Text(
            content,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buttonAccept(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 20),
      child: ElevatedButton(
        onPressed: _con.updateOrder,
        style: ElevatedButton.styleFrom(
            primary: _con.order!.status == 'DESPACHADO'
                ? Colors.blue
                : Colors.green,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            )
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  _con.order!.status == 'DESPACHADO'
                      ? 'RECOGER PEDIDO'
                      : 'IR AL MAPA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50, top: 4),
                height: 30,
                child: Icon(
                  Icons.directions_car,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonNext(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 20),
      child: ElevatedButton(
        onPressed: _con.updateOrder,
        style: ElevatedButton.styleFrom(
            primary: _con.order!.status == 'DESPACHADO'
                ? Colors.blue
                : Colors.green,
            padding: EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
            )
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  _con.order!.status == 'DESPACHADO'
                    ? 'INICIAR ENTREGA'
                    : 'IR AL MAPA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: 50, top: 4),
                height: 30,
                child: Icon(
                  Icons.directions_car,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void refresh(){
    setState(() {

    });
  }
}
