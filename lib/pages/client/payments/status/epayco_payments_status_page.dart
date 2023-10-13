import 'package:delivery/pages/client/payments/status/epayco_payments_status_controller.dart';
import 'package:delivery/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class EpaycoPaymentsStatusPage extends StatefulWidget {
  @override
  _EpaycoPaymentsStatusPage createState() => _EpaycoPaymentsStatusPage();
}

class _EpaycoPaymentsStatusPage extends State<EpaycoPaymentsStatusPage> {

  EpaycoPaymentsStatusController _con = EpaycoPaymentsStatusController();

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _clipPathOval(),
          _textCardDetail(),
          _textCardStatus(),
        ]
      ),
      bottomNavigationBar: Container(
        height: 100,
          child: _buttonNext(),
      ),
    );
  }
  Widget _textCardDetail(){
    print('MENSAJE A MOSTRAR: ' + _con.status);
    return _con.status == 'true' ? Text(
        'Tu orden fue procesada exitosamente usando '
            '(${_con.brandCard}'
            ') **** ${_con.last4}',
        style: TextStyle(
            fontSize: 17
        ),
        textAlign: TextAlign.center,
      ) : Text(
        'Lo sentimos, su pago fue rechazado',
        style: TextStyle(
            fontSize: 17
        ),
        textAlign: TextAlign.center,
      );
  }

  Widget _textCardStatus(){
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child:  _con.status == 'true' ? Text(
        'Mira el estado de tu compra en la seccion de Mis pedidos',
        style: TextStyle(
          fontSize: 17
        ),
        textAlign: TextAlign.center,
      ) : Text(
        _con.errorMessage,
        style: TextStyle(
            fontSize: 17
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _clipPathOval(){
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        height: 250,
        width: double.infinity,
        color: MyColors.primaryColor,
        child: SafeArea(
          child: Column(
            children: [
               _con.status == 'true'
                ? Icon(Icons.check_circle, color: Colors.green,size: 150,)
                  : Icon(Icons.cancel, color: Colors.red,size: 150,),
              Text(
                _con.status == 'true'
                  ? 'Gracias por tu compra'
                      : 'Fallo la transaccion',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonNext(){
    return Container(
      height: 50,
      margin: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: _con.finishShopping,
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
                height: 30,
                alignment: Alignment.center,
                child: Text(
                  'FINALIZAR COMPRA',
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
                margin: EdgeInsets.only(left: 50,),
                height: 30,
                child: Icon(
                  Icons.arrow_forward_ios,
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
