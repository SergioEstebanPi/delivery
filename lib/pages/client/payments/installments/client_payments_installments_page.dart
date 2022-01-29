import 'package:delivery/models/mercado_pago_document_type.dart';
import 'package:delivery/models/mercado_pago_installment.dart';
import 'package:delivery/models/user.dart';
import 'package:delivery/pages/client/payments/create/client_payments_create_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import 'client_payments_installments_controller.dart';

class ClientPaymentsInstallmentsPage extends StatefulWidget {
  @override
  _ClientPaymentsInstallmentsPageState createState() => _ClientPaymentsInstallmentsPageState();
}

class _ClientPaymentsInstallmentsPageState extends State<ClientPaymentsInstallmentsPage> {

  ClientPaymentsInstallmentsController _con = ClientPaymentsInstallmentsController();

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
        title: Text('Cuotas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textDescription(),
          _dropDownInstallments(),
        ]
      ),
      bottomNavigationBar: Container(
        height: 140,
          child: Column(
            children: [
              _textTotalPrice(),
              _buttonNext(),
            ],
          )
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropItems (List<MercadoPagoInstallment> installmentsList){
    List<DropdownMenuItem<String>> list = [];
    if(installmentsList != null){
      installmentsList.forEach((installment) {
        list.add(DropdownMenuItem(
          child: Container(
            margin: EdgeInsets.only(top: 7),
            child: Text('${installment.installments!}'),
          ),
          value: '${installment.installments!}',
        ));
      });
    }
    return list;
  }

  Widget _textDescription(){
    return Container(
       margin: EdgeInsets.all(30),
      child: Text(
          'En cuantas cuotas',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _dropDownInstallments(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                    'Seleccionar numero de cuotas',
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
                  items: _dropItems(_con.installmentsList),
                  value: _con.selectedInstallment,
                  onChanged: (option) {
                    setState(() {
                      print('Cuota seleccionada $option');
                      _con.selectedInstallment = option!; // establece el valor seleccionado
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

  Widget _textTotalPrice(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              'Total a pagar:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
          ),
          Text(
            '${_con.totalPayment}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonNext(){
    return Container(
      height: 50,
      margin: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _con.createPay,
        //onPressed: _con.createCardToken,
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
                  'CONFIRMAR PAGO',
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
                margin: EdgeInsets.only(left: 60,),
                height: 30,
                child: Icon(
                  Icons.attach_money,
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
