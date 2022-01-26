import 'package:delivery/models/order.dart';
import 'package:delivery/pages/delivery/orders/list/delivery_orders.list_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:delivery/widgets/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DeliveryOrdersListPage extends StatefulWidget {
  @override
  _DeliveryOrdersListPageState createState() => _DeliveryOrdersListPageState();
}

class _DeliveryOrdersListPageState extends State<DeliveryOrdersListPage> {

  DeliveryOrdersListController _con = DeliveryOrdersListController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _con.categories.length,
      child: Scaffold(
        key: _con.key,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              //_shoppingBag()
            ],
            flexibleSpace: Column(
              children: [
                SizedBox(height: 60,),
                _menuDrawer(),
              ],
            ),
            bottom: TabBar(
              indicatorColor: MyColors.primaryColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              isScrollable: true,
              tabs: List<Widget>.generate(_con.categories.length, (index) {
                return Tab(
                  child: Text(_con.categories[index]),
                );
              }
              ),
            ),
          ),
        ),
        drawer: _drawer(),
        body: TabBarView(
          children: _con.categories.map((String category) {
            return FutureBuilder(
                future: _con.getOrders(category),
                builder: (context, AsyncSnapshot<List<Order>?> snapshot) {
                  if(snapshot != null && snapshot.hasData){
                    if(snapshot.data!.length > 0){
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                        itemBuilder: (_, index) {
                          return  _cardOrder(snapshot.data![index]);
                        },
                      );
                    } else {
                      return NoDataWidget(
                          text: "No hay productos"
                      );
                    }
                  } else {
                    return NoDataWidget(
                        text: "No hay productos"
                    );
                  }
                }
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _cardOrder(Order order){
    return GestureDetector(
      onTap: () {
        _con.openBottomSheet(order);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        height: 155,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: MyColors.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Order #${order.id}',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontFamily: 'NimbusSans'
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: Text(
                        'Pedido: ${order.timestamp}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: Text(
                        'Cliente: ${order.client!.name ?? ''} ${order.client!.lastname ?? ''}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      width: double.infinity,
                      child: Text(
                        'Entregar en: ${order.address!.address ?? ''}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuDrawer() {
    return GestureDetector(
      onTap: () {
        _con.openDrawer();
      },
      child: Container(
        margin: EdgeInsets.only(
            left: 20
        ),
        alignment: Alignment.centerLeft,
        child: Image.asset('assets/img/menu.png', width: 20, height: 20,),
      ),
    );
  }

  Widget _drawer() {
    var userImage;
    if (_con.user?.image != null) {
      userImage = NetworkImage(_con.user!.image!);
    } else {
      userImage = AssetImage('assets/img/no-image.png');
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                  color: MyColors.primaryColor
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_con.user?.name ?? ''} ${_con.user?.lastname ?? ''}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    '${_con.user?.email ?? ''}',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                    maxLines: 1,
                  ),
                  Text(
                    '${_con.user?.phone ?? ''}',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[200],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                    ),
                    maxLines: 1,
                  ),
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 10),
                    child: FadeInImage(
                      image: userImage,
                      fit: BoxFit.contain,
                      fadeInDuration: Duration(milliseconds: 50),
                      placeholder: AssetImage('assets/img/no-image.png'),
                    ),
                  ),
                ],
              )
          ),
          ListTile(
            title: Text('Editar perfil'),
            trailing: Icon(Icons.edit_outlined),
          ),
          _con.user != null ?
          _con.user!.roles!.length > 1 ?
          ListTile(
            onTap: _con.goToRoles,
            title: Text('Seleccionar rol'),
            trailing: Icon(Icons.person_outlined),
          ): Container()
              : Container(),
          ListTile(
            onTap: () {
              _con.logout();
            },
            title: Text('Cerrar sesion'),
            trailing: Icon(Icons.power_settings_new),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
