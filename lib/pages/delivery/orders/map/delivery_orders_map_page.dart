import '../../../delivery/orders/map/delivery_orders_map_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryOrdersMapPage extends StatefulWidget {
  @override
  _DeliveryOrdersMapPageState createState() => _DeliveryOrdersMapPageState();
}

class _DeliveryOrdersMapPageState extends State<DeliveryOrdersMapPage> {

  DeliveryOrdersMapController _con = DeliveryOrdersMapController();

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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
              child: _googleMaps()
          ),
          SafeArea(
            child: Column(
              children: [
                _buttonCenterPosition(),
                Spacer(),
                _cardOrderInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonCenterPosition(){
    return GestureDetector(
      onTap: (){},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20,),
        alignment: Alignment.centerRight,
        child: Card(
          shape: CircleBorder(),
          color: Colors.white,
          elevation: 4,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Icon(
                Icons.location_searching,
                color: Colors.grey[600],
                size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleMaps(){
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _con.initialPosition,
      onMapCreated: _con.onMapCreated,
      //myLocationButtonEnabled: true,
      //myLocationEnabled: true,
      markers: Set<Marker>.of(_con.markers!.values),
      polylines: _con.polylines,
    );
  }

  Widget _cardOrderInfo(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0,3),
          )
        ]
      ),
      child: Column(
        children: [
          _listTileAddress(
              _con.order != null ? _con.order!.address!.neighborhood! : '',
              'Barrio',
              Icons.my_location
          ),
          _listTileAddress(
              _con.order != null ? _con.order!.address!.address!: '',
              'Direccion',
              Icons.location_on
          ),
          Divider(
            color: Colors.grey[400],
            endIndent: 30,
            indent: 30,
          ),
          _clientInfo(),
          _buttonAccept(),
        ],
      ),
    );
  }

  Widget _clientInfo(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 20,),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            child: FadeInImage(
              image:  _con.order != null && _con.order!.client!.image != null
                  ? NetworkImage(_con.order!.client!.image!)
                  : AssetImage('assets/img/no-image.png') as ImageProvider,
              fit: BoxFit.cover,
              fadeInDuration: Duration(milliseconds: 50),
              placeholder: AssetImage(
                  'assets/img/no-image.png'
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              _con.order != null
                  ? '${_con.order!.client!.name!} ${_con.order!.client!.lastname!}'
                : '',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              maxLines: 1,
            ),
          ),
          Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.grey[200],
            ),
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.phone,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listTileAddress(String title, String subtitle, IconData iconData){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30,),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(iconData),
      ),
    );
  }

  Widget _buttonAccept(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 10),
      child: ElevatedButton(
        onPressed: () {},
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
                  'ENTREGAR PRODUCTO',
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
                margin: EdgeInsets.only(left: 35, top: 4),
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
