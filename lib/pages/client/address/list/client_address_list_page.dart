import 'package:delivery/models/address.dart';
import 'package:delivery/pages/client/address/list/client_address_list_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:delivery/widgets/no_data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ClientAddressListPage extends StatefulWidget {
  @override
  _ClientAddressListPageState createState() => _ClientAddressListPageState();
}

class _ClientAddressListPageState extends State<ClientAddressListPage> {

  ClientAddressListController _con = ClientAddressListController();

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
        title: Text('Direcciones'),
        actions: [
          _iconAdd(),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: _textSelectAddress(),
          ),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: _listAddress()
          ),
        ],
      ),
      bottomNavigationBar: _buttonAccept(),
    );
  }

  Widget _iconAdd(){
    return IconButton(
      onPressed: _con.goToNewAddress,
      icon: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  Widget _noAddress(){
    return Column(
      children: [
        Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 30),
            child: NoDataWidget(
                text: 'Agrega una nueva direccion'
            )
        ),
        _buttonNewAddress(),
      ],
    );
  }

  Widget _textSelectAddress(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Text(
        'Elige donde recibir tus compras',
        style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _listAddress(){
    return FutureBuilder(
        future: _con.getAddress(),
        builder: (context, AsyncSnapshot<List<Address>> snapshot) {
          if(snapshot.hasData){
            if(snapshot.data!.isNotEmpty){
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                itemBuilder: (_, index) {
                  return _radioSelectorAddress(snapshot.data![index], index);
                },
              );
            } else {
              return _noAddress();
            }
          } else {
            return Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation(Colors.grey),
              )
            );
          }
        }
    );
  }

  Widget _radioSelectorAddress(Address address, int index){
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 20,),
      child: Column(
        children: [
          Row(
            children: [
              Radio(
                value: index,
                onChanged: _con.handleRadioValueChange,
                groupValue: _con.radioValue,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.address ?? '',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold
                    ),
                  )  ,
                  Text(
                    address.neighborhood ?? '',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ],
          ),
          Divider(
            color: Colors.grey[400],
          ),
        ],
      )
    );
  }

  Widget _buttonNewAddress(){
    return Container(
      height: 40,
      child: ElevatedButton(
        onPressed: _con.goToNewAddress,
        child: Text(
            'Nueva direccion'
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
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
        onPressed: _con.createOrder,
        child: Text(
          'PAGAR'
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
