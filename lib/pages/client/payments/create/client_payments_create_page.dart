import 'package:delivery/models/user.dart';
import 'package:delivery/pages/client/payments/create/client_payments_create_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

class ClientPaymentsCreatePage extends StatefulWidget {
  @override
  _ClientPaymentsCreatePageState createState() => _ClientPaymentsCreatePageState();
}

class _ClientPaymentsCreatePageState extends State<ClientPaymentsCreatePage> {

  ClientPaymentsCreateController _con = ClientPaymentsCreateController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagos'),
      ),
      body: ListView(
        children: [
          CreditCardWidget(
            cardNumber: _con.cardNumber,
            expiryDate: _con.expiryDate,
            cardHolderName: _con.cardHolderName,
            cvvCode: _con.cvvCode,
            showBackView: _con.isCvvFocused,
            cardBgColor: MyColors.primaryColor,
            obscureCardNumber: true,
            obscureCardCvv: true,
            height: 175,
            textStyle: TextStyle(color: Colors.white),
            width: MediaQuery.of(context).size.width,
            animationDuration: Duration(milliseconds: 1000),
            labelCardHolder: 'NOMBRE Y APELLIDO',
          ),

          CreditCardForm(
            formKey: _con.keyForm, // Required
            onCreditCardModelChange: _con.onCreditCardModelChange, // Required
            themeColor: Colors.white,
            obscureCvv: true,
            obscureNumber: true,
            cardNumberDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Numero de la tarjeta',
              hintText: 'XXXX XXXX XXXX XXXX',
            ),
            expiryDateDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Fecha de expiracion',
              hintText: 'XX/XX',
            ),
            cvvCodeDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'CVV',
              hintText: 'XXX',
            ),
            cardHolderDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Nombre del titular',
            ),
            cardNumber: _con.cardNumber,
            expiryDate: _con.expiryDate,
            cardHolderName: _con.cardHolderName,
            cvvCode: _con.cvvCode,
          ),

          _documentInfo(),
          _buttonNext(),

        ],
      ),
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

  Widget _documentInfo(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: Material(
              elevation: 2.0,
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButton<String>(
                        elevation: 3,
                        isExpanded: true,
                        hint: const Text(
                          'C.C.',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16
                          ),
                        ),
                        underline: Container(
                          margin: EdgeInsets.only(right: 0, left: 0, bottom: 5),
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_drop_down_circle,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        items: _dropItems([]),
                        value: '',
                        onChanged: (option) {
                          setState(() {
                            print('Repartidor seleccionado $option');
                            //_con.idDelivery = option; // establece el valor seleccionado
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          Flexible(
            flex: 4,
            child: TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Numero de documento',
              ),
              cursorColor: Colors.black,
            ),
          )
        ]
      ),
    );
  }

  Widget _buttonNext(){
    return Container(
      margin: EdgeInsets.all(20),
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
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'CONTINUAR',
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
                margin: EdgeInsets.only(left: 50, top: 7),
                height: 30,
                child: Icon(
                  Icons.arrow_forward_ios,
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
