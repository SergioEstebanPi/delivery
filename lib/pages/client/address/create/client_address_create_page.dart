import 'package:delivery/pages/client/address/create/client_address_create_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientAddressCreatePage extends StatefulWidget {
  @override
  _ClientAddressCreatePageState createState() => _ClientAddressCreatePageState();
}

class _ClientAddressCreatePageState extends State<ClientAddressCreatePage> {

  ClientAddressCreateController _con = ClientAddressCreateController();

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
      appBar: AppBar(
        title: Text('Nueva direccion'),
      ),
      bottomNavigationBar: _buttonAccept(),
      body: Column(
        children: [
          _textSelectAddress(),
          _textFieldAddress(),
          _textFieldNeighborhood(),
          _textFieldRefPoint(),
        ],
      ),
    );
  }

  Widget _textSelectAddress(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Text(
        'Completa estos datos',
        style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _textFieldAddress(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Direccion',
          suffixIcon: Icon(
            Icons.location_on,
            color: MyColors.primaryColor,
          )
        ),
      ),
    );
  }

  Widget _textFieldNeighborhood(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
            labelText: 'Barrio',
            suffixIcon: Icon(
              Icons.location_city,
              color: MyColors.primaryColor,
            )
        ),
      ),
    );
  }

  Widget _textFieldRefPoint(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        controller: _con.refPointController,
        onTap: _con.openMap,
        autofocus: false,
        focusNode: AlwaysDisabledFocusNode(),
        decoration: InputDecoration(
            labelText: 'Punto de referencia',
            suffixIcon: Icon(
              Icons.map,
              color: MyColors.primaryColor,
            )
        ),
      ),
    );
  }

  Widget _buttonAccept(){
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
            'CREAR DIRECCION'
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)
          ),
          primary: MyColors.primaryColor,
        ),
      ),
    );
  }

  void refresh(){
    setState(() {

    });
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
