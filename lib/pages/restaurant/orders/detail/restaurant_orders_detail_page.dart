import 'package:delivery/models/order.dart';
import 'package:delivery/models/product.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/pages/restaurant/orders/detail/restaurant_orders_detail_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:delivery/utils/relative_time_util.dart';
import 'package:delivery/widgets/no_data_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RestaurantOrdersDetailPage extends StatefulWidget {

  Order order;

  RestaurantOrdersDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _RestaurantOrdersDetailPageState createState() => _RestaurantOrdersDetailPageState();
}

class _RestaurantOrdersDetailPageState extends State<RestaurantOrdersDetailPage> {

  RestaurantOrdersCreateController _con = RestaurantOrdersCreateController();

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
                _textDescription(),
                SizedBox(height: 10,),
                _con.order!.status != 'PAGADO'
                  ?_deliveryData()
                  : Container(),
                _con.order!.status == 'PAGADO'
                  ? _dropDownUsers(_con.users)
                    : Container(),
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
                _con.order!.status == 'PAGADO'
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

  List<DropdownMenuItem<String>> _dropItems (List<User> users){
    List<DropdownMenuItem<String>> list = [];
    if(users != null){
      users.forEach((user) {
        list.add(DropdownMenuItem(
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                margin: EdgeInsets.only(top: 5, bottom: 5),
                child: FadeInImage(
                  image:  user.image != null
                      ? NetworkImage(user.image!)
                      : AssetImage('assets/img/no-image.png') as ImageProvider,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 50),
                  placeholder: AssetImage('assets/img/no-image.png'),
                ),
              ),
              SizedBox(width: 5,),
              Text(user.name!),
            ],
          ),
          value: user.id,
        ));
      });
    }
    return list;
  }

  Widget _deliveryData (){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: FadeInImage(
              image:  _con.order!.delivery!.image != null
                  ? NetworkImage(_con.order!.delivery!.image!)
                  : AssetImage('assets/img/no-image.png') as ImageProvider,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage('assets/img/no-image.png'),
            ),
          ),
          SizedBox(width: 5,),
          Text(
              '${_con.order!.delivery!.name!} ${_con.order!.delivery!.lastname!}'
          ),
        ],
      ),
    );
  }

  Widget _textDescription(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Text(
          _con.order!.status == 'PAGADO'
            ? 'Asignar repartidor'
            : 'Repartidor asignado',
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: MyColors.primaryColor,
          ),
      ),
    );
  }

  Widget _dropDownUsers(List<User> users){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Material(
        elevation: 2.0,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: Container(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: DropdownButton<String>(
                  elevation: 3,
                  isExpanded: true,
                  hint: const Text(
                    'Seleccionar repartidor',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16
                    ),
                  ),
                  underline: Container(
                    margin: EdgeInsets.only(right: 0, left: 250),
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_drop_down_circle,
                      color: MyColors.primaryColor,
                    ),
                  ),
                  items: _dropItems(users),
                  value:_con.idDelivery,
                  onChanged: (option) {
                    setState(() {
                      print('Repartidor seleccionado $option');
                      _con.idDelivery = option; // establece el valor seleccionado
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
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
        onPressed: _con.updateOrder,
        style: ElevatedButton.styleFrom(
            primary: MyColors.primaryColor,
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
                  'DESPACHAR ORDEN',
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
                  Icons.check_circle,
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
