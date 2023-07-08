import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/pages/client/orders/detail/client_orders_detail_controller.dart';
import 'package:delivery/pages/delivery/orders/detail/delivery_orders_detail_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:delivery/utils/relative_time_util.dart';
import 'package:delivery/widgets/no_data_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientOrdersDetailPage extends StatefulWidget {

  Order order;

  ClientOrdersDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _ClientOrdersDetailPageState createState() => _ClientOrdersDetailPageState();
}

class _ClientOrdersDetailPageState extends State<ClientOrdersDetailPage> {

  ClientOrdersCreateController _con = ClientOrdersCreateController();

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
        height: MediaQuery.of(context).size.height * 0.4,
        child: SingleChildScrollView(
          child: Column(
              children: [
                Divider(
                  color: Colors.grey[400],
                  endIndent: 30, // margen derecho
                  indent: 30, // margen izquierdo
                ),
                SizedBox(height: 10,),
                //_textData('Restaurante:', _con.order!.idUser!),
                _textData('Repartidor:', _con.order != null &&_con.order!.delivery!.id != null
                    ? '${_con.order!.delivery!.name} ${_con.order!.delivery!.lastname}'
                    : 'No asignado'),
                _textData('Entregar en:', _con.order != null
                    ? '${_con.order!.address!.address}'
                    : ''),
                _textData(
                    'Fecha de pedido:',
                    _con.order != null
                        ? '${RelativeTimeUtil.getRelativeTime(_con.order!.timestamp ?? 0)}'
                        : ''
                ),
                _con.order != null && _con.order!.status == 'PAGADO'
                    ? _buttonCancel()
                    : _con.order != null && _con.order!.status == 'EN CAMINO'
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

  Widget _buttonNext(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 20),
      child: ElevatedButton(
        onPressed: _con.showMap,
        style: ElevatedButton.styleFrom(
            primary: Colors.blue,
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
                  'SEGUIR ENTREGA',
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
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlertDialog(Order order){
    Widget cancelButton = ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text('NO'),
    );
    Widget confirmButton = ElevatedButton(
      onPressed: () {
        _con.confirmCancelation(order);
      },
      child: Text('SI'),
    );

    AlertDialog alertDialog = AlertDialog(
      title: Text('Confirmas que deseas cancelar el pedido?'),
      actions: [
        cancelButton,
        confirmButton
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return alertDialog;
        }
    );
  }

  Widget _buttonCancel(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 20),
      child: ElevatedButton(
        onPressed: () {showAlertDialog(_con.order!);},
        style: ElevatedButton.styleFrom(
            primary: Colors.red,
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
                  'CANCELAR PEDIDO',
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
                  Icons.clear,
                  color: Colors.white,
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
